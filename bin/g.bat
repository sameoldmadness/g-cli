@echo off
setlocal

set VERSION=0.0.6
set arg1=%~1

if not defined arg1 call:displayLocalBranches&goto:exit

if "%arg1%"=="-r" call:displayRemoteBranches&goto:exit
if "%arg1%"=="--remote" call:displayRemoteBranches&goto:exit
if "%arg1%"=="remote" call:displayRemoteBranches&goto:exit

if "%arg1%"=="-v" call:displayVersion&goto:exit
if "%arg1%"=="--version" call:displayVersion&goto:exit
if "%arg1%"=="version" call:displayVersion&goto:exit

if "%arg1%"=="-h" call:displayHelp&goto:exit
if "%arg1%"=="--help" call:displayHelp&goto:exit
if "%arg1%"=="help" call:displayHelp&goto:exit

call:displayHelp&goto:exit

:exec
setlocal
  (for /f "delims=" %%i in ('%~1') do set res=%%i) 2>nul
(endlocal
  set %~2=%res%
)
goto:eof

:displayLocalBranches
setlocal
  cls
  call:checkCurrentBranch branch
  call:displayLocalBranchesWithSelected %branch%
endlocal
goto:eof

:checkCurrentBranch
setlocal
  call:currentBranch branch
  if not defined branch call:currentHead branch
(endlocal
  set %~1=%branch%
)
goto:eof

:currentBranch
  call:exec "git symbolic-ref --short -q HEAD" %~1
goto:eof

:currentHead
  call:exec "git rev-parse --short HEAD" %~1
goto:eof

:displayLocalBranchesWithSelected
setlocal
  set cmd="git for-each-ref --format=%%(refname:short) refs/heads"
  (for /f "delims=" %%i in ('%cmd%') do (
    if "%%i"=="%~1" (echo.* %%i) else (echo.  %%i)
  )) 2>nul
endlocal
goto:eof

:displayRemoteBranches
  echo.show remote branches
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
