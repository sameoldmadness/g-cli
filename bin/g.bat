@echo off
setlocal

set VERSION=1.0.1

call:display %1
goto:exit

:display :: (key)
setlocal
  set action=displayHelp

  if "%1"=="" set action=runLoop local

  if "%1"=="-r" set action=runLoop remote
  if "%1"=="--remote" set action=runLoop remote
  if "%1"=="remote" set action=runLoop remote

  if "%1"=="-v" set action=displayVersion
  if "%1"=="--version" set action=displayVersion
  if "%1"=="version" set action=displayVersion

  if "%1"=="-h" set action=displayHelp
  if "%1"=="--help" set action=displayHelp
  if "%1"=="help" set action=displayHelp

  call:%action%
endlocal
goto:eof

:runLoop :: (type)
setlocal
  cls
  call:getCurrentBranch branch
  call:getBranches %1 branches
  call:readKey %1 %branch% "%branches%"
endlocal
goto:eof

:getCurrentBranch :: (*branch)
setlocal
  call:exec "git symbolic-ref --short -q HEAD" return
  if not defined return call:exec "git rev-parse --short HEAD" return
endlocal & set %1=%return%
goto:eof

:getBranches :: (type. *branches)
setlocal EnableDelayedExpansion
  set local="git for-each-ref --format=%%%%(refname:short) refs/heads"
  set remote="git ls-remote --heads origin"

  call:execMap !%1! formatBranchName ";" return
endlocal & set %2=%return%
goto:eof

:exec :: (cmd, *output)
setlocal
  (for /f "delims=" %%i in ('%~1') do set return=%%i) 2>nul
endlocal & set %2=%return%
goto:eof

:readKey :: (type, branch, branches)
setlocal
  call:displayBranches %2 "%~3"

  choice /c wasd /n
  cls

  if "%errorlevel%"=="1" call:changeBranch %2 "%~3" up branch
  if "%errorlevel%"=="2" goto:exit
  if "%errorlevel%"=="3" call:changeBranch %2 "%~3" down branch
  if "%errorlevel%"=="4" call:activate %1 %2 & goto:exit

  call:readKey %1 %branch% "%~3"
endlocal
goto:eof

:displayBranches :: (branch, branches)
setlocal
  for %%i in (%branches%) do if "%%i"=="%1" (echo.* %%i) else (echo.  %%i)
endlocal
goto:eof

:activate :: (type, branch)
setlocal EnableDelayedExpansion
  set local=git checkout %2
  set remote=git checkout -b %2 origin/%2

  !%1!
endlocal
goto:eof

:execMap :: (command, callback, delimiter, *output)
setlocal EnableDelayedExpansion
  (for /f "delims=" %%i in ('%1') do (
    call:%2 "%%i" item
    set return=!return!%~3!item!
  )) 2>nul
endlocal & set %4=%return:~1%
goto:eof

:formatBranchName :: (string, *formatted)
setlocal
  set value=%~1
endlocal & set %2=%value:*refs/heads/=%
goto:eof

:changeBranch :: (branch, branches, direction, *nextBranch)
setlocal EnableDelayedExpansion
  set /a index=0
  if "%3"=="up" (set sign=-) else (set sign=+)
  for %%i in (%~2) do (
    set /a index+=1
    set branches[!index!]=%%i
    if "%%i"=="%~1" set /a branchIndex=!index!
  )
  set /a branchIndex%sign%=1
  set return=!branches[%branchIndex%]!
endlocal & (if "%return%"=="" (set %4=%1) else (set %4=%return%))
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
