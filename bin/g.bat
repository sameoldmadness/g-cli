@echo off
setlocal

set VERSION=0.0.6

set GIT_LOCAL_BRANCHES="git for-each-ref --format=%%%%(refname:short) refs/heads"
set GIT_REMOTE_BRANCHES="git ls-remote --heads origin"

call:display %1
goto:exit

:display
setlocal
  set action=displayHelp

  if "%1"=="" set action=runLoop Local

  if "%1"=="-r" set action=runLoop Remote
  if "%1"=="--remote" set action=runLoop Remote
  if "%1"=="remote" set action=runLoop Remote

  if "%1"=="-v" set action=displayVersion
  if "%1"=="--version" set action=displayVersion
  if "%1"=="version" set action=displayVersion

  if "%1"=="-h" set action=displayHelp
  if "%1"=="--help" set action=displayHelp
  if "%1"=="help" set action=displayHelp

  call:%action%
endlocal
goto:eof

:runLoop
setlocal EnableDelayedExpansion
  cls
  call:getCurrentBranch branch
  call:execMap !GIT_%1_BRANCHES! passthrough ";" branches
  call:readKey %1 %branch% "%branches%"
endlocal
goto:eof

:getCurrentBranch
setlocal
  call:exec return "git symbolic-ref --short -q HEAD"
  if not defined return call:exec return "git rev-parse --short HEAD"
endlocal & set %~1=%return%
goto:eof

:exec
setlocal
  (for /f "delims=" %%i in ('%~2') do set return=%%i) 2>nul
endlocal & set %~1=%return%
goto:eof

:readKey :: (type, branch, branches)
setlocal
  set branch=%2
  call:displayBranches %branch% "%~3"

  choice /c wasd /n
  cls

  if "%errorlevel%"=="1" call:changeBranch branch "%~3" up
  if "%errorlevel%"=="2" goto:exit
  if "%errorlevel%"=="3" call:changeBranch branch "%~3" down
  if "%errorlevel%"=="4" call:activate%1 %branch%&goto:exit

  call:readKey %1 %branch% "%~3"
endlocal
goto:eof

:displayBranches :: (branch, branches)
setlocal
  for %%i in (%branches%) do if "%%i"=="%1" (echo.* %%i) else (echo.  %%i)
endlocal
goto:eof

:activateLocal
setlocal
  call:getCurrentBranch current
  if not "%~1"=="%current%" git checkout %~1
endlocal
goto:eof

:activateRemote
setlocal
  git checkout -b %~1 origin/%~1
endlocal
goto:eof

:execMap :: (command, callback, delimiter, return)
setlocal EnableDelayedExpansion
  (for /f "delims=" %%i in ('%1') do (
    call:%2 "%%i" item
    set return=!return!%~3!item!
  )) 2>nul
endlocal & set %4=%return:~1%
goto:eof

:passthrough :: (value, return)
setlocal
  set value=%~1
endlocal & set %2=%value:*refs/heads/=%
goto:eof

:changeBranch :: (branch, branches, direction)
setlocal EnableDelayedExpansion
  set /a index=0
  if "%3"=="up" (set sign=-) else (set sign=+)
  for %%i in (%~2) do (
    set /a index+=1
    set branches[!index!]=%%i
    if "%%i"=="!%~1!" set /a branchIndex=!index!
  )
  set /a branchIndex%sign%=1
  set return=!branches[%branchIndex%]!
endlocal & if not "%return%"=="" set %~1=%return%
goto:eof

:displayHelp
  echo.
  echo.  Usage: g [options] [COMMAND]
  echo.
  echo.  Commands:
  echo.
  echo.    g               Output local branches installed
  echo.
  echo.  Options:
  echo.
  echo.    -v, --version   Output current version of g
  echo.    -h, --help      Display help information
  echo.    -r, --remote    Create local branch from remote
  echo.
goto:eof

:displayVersion
  echo %VERSION%
goto:eof

:exit
  endlocal
