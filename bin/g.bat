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
setlocal
  cls
  call:getCurrentBranch branch
  call:readKey %1 %branch%
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

:readKey
setlocal
  set branch=%2
  call:displayBranches %1 %branch%

  choice /c wasd /n
  cls

  if "%errorlevel%"=="1" call:prev%1Branch branch
  if "%errorlevel%"=="2" goto:exit
  if "%errorlevel%"=="3" call:next%1Branch branch
  if "%errorlevel%"=="4" call:activate%1 %branch%&goto:exit

  call:readKey %1 %branch%
endlocal
goto:eof

:execEach
setlocal
  (for /f "delims=" %%i in ('%1') do call:%~2 "%%i") 2>nul
endlocal
goto:eof

:displayBranches
setlocal EnableDelayedExpansion
  call:execEach !GIT_%1_BRANCHES! "display%1Branch %2"
endlocal
goto:eof

:displayLocalBranch
setlocal
  if "%1"=="%~2" (echo.* %~2) else (echo.  %~2)
endlocal
goto:eof

:displayRemoteBranch
setlocal
  set head=%~2
  call:displayLocalBranch %head:*refs/heads/=% %1
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

:prevLocalBranch
setlocal EnableDelayedExpansion
  set /a counter=0
  set cmd="git for-each-ref --format=%%(refname:short) refs/heads"
  (for /f "delims=" %%i in ('%cmd%') do (
    set branches[!counter!]=%%i
    if "%%i"=="!%~1!" set /a curBranchIndex=!counter!
    set /a counter+=1
  )) 2>nul
  set /a nextBranchIndex=curBranchIndex-1
  set nextBranch=!branches[%nextBranchIndex%]!
endlocal & if not "%nextBranch%"=="" set %~1=%nextBranch%
goto:eof

:nextLocalBranch
setlocal EnableDelayedExpansion
  set /a counter=0
  set cmd="git for-each-ref --format=%%(refname:short) refs/heads"
  (for /f "delims=" %%i in ('%cmd%') do (
    set branches[!counter!]=%%i
    if "%%i"=="!%~1!" set curBranchIndex=!counter!
    set /a counter+=1
  )) 2>nul
  set /a nextBranchIndex=curBranchIndex+1
  set nextBranch=!branches[%nextBranchIndex%]!
endlocal & if not "%nextBranch%"=="" set %~1=%nextBranch%
goto:eof

:prevRemoteBranch
setlocal EnableDelayedExpansion
  set /a counter=0
  set cmd="git ls-remote --heads origin"
  (for /f "delims=" %%i in ('%cmd%') do (
    set ref=%%i
    set name=!ref:*refs/heads/=!
    set branches[!counter!]=!name!
    if "!name!"=="!%~1!" set /a curBranchIndex=!counter!
    set /a counter+=1
  )) 2>nul
  set /a nextBranchIndex=curBranchIndex-1
  set nextBranch=!branches[%nextBranchIndex%]!
endlocal & if not "%nextBranch%"=="" set %~1=%nextBranch%
goto:eof

:nextRemoteBranch
setlocal EnableDelayedExpansion
  set /a counter=0
  set cmd="git ls-remote --heads origin"
  (for /f "delims=" %%i in ('%cmd%') do (
    set ref=%%i
    set name=!ref:*refs/heads/=!
    set branches[!counter!]=!name!
    if "!name!"=="!%~1!" set /a curBranchIndex=!counter!
    set /a counter+=1
  )) 2>nul
  set /a nextBranchIndex=curBranchIndex+1
  set nextBranch=!branches[%nextBranchIndex%]!
endlocal & if not "%nextBranch%"=="" set %~1=%nextBranch%
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
