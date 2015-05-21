@echo off
setlocal

set VERSION=0.0.6

call:display %1
goto:exit

:display
setlocal
  set action=Help

  if "%1"=="" set action=LocalBranches

  if "%1"=="-r" set action=RemoteBranches
  if "%1"=="--remote" set action=RemoteBranches
  if "%1"=="remote" set action=RemoteBranches

  if "%1"=="-v" set action=Version
  if "%1"=="--version" set action=Version
  if "%1"=="version" set action=Version

  if "%1"=="-h" set action=Help
  if "%1"=="--help" set action=Help
  if "%1"=="help" set action=Help

  call:display%action%
endlocal
goto:eof

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
  call:readKeyLocal %branch%
endlocal
goto:eof

:readKeyLocal
call:displayLocalBranchesWithSelected %branch%

choice /c wasd /n
cls

if "%errorlevel%"=="1" call:prevLocalBranch branch
if "%errorlevel%"=="2" goto:exit
if "%errorlevel%"=="3" call:nextLocalBranch branch
if "%errorlevel%"=="4" call:activate %branch%&goto:exit

call:readKeyLocal %branch%
goto:eof

:activate
setlocal
  call:checkCurrentBranch current
  if "%~1"=="%current%" (type nul) else git checkout %~1
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
(endlocal
  if "%nextBranch%"=="" (type nul) else (set %~1=%nextBranch%)
)
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
(endlocal
  if "%nextBranch%"=="" (type nul) else (set %~1=%nextBranch%)
)
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
setlocal
  cls
  call:checkCurrentBranch branch
  call:readKeyRemote %branch%
endlocal
goto:eof

:readKeyRemote
call:displayRemoteBranchesWithSelected %branch%

choice /c wasd /n
cls

if "%errorlevel%"=="1" call:prevRemoteBranch branch
if "%errorlevel%"=="2" goto:exit
if "%errorlevel%"=="3" call:nextRemoteBranch branch
if "%errorlevel%"=="4" call:createFromRemote %branch%&goto:exit

call:readKeyRemote %branch%
goto:eof

:displayRemoteBranchesWithSelected
setlocal EnableDelayedExpansion
  set cmd="git ls-remote --heads origin"
  (for /f "delims=" %%i in ('%cmd%') do (
    set ref=%%i
    set name=!ref:*refs/heads/=!
    if "!name!"=="%~1" (echo.* !name!) else (echo.  !name!)
  )) 2>nul
endlocal
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
(endlocal
  if "%nextBranch%"=="" (type nul) else (set %~1=%nextBranch%)
)
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
(endlocal
  if "%nextBranch%"=="" (type nul) else (set %~1=%nextBranch%)
)
goto:eof

:createFromRemote
  git checkout -b %~1 origin/%~1
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
