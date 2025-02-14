@echo off
REM Define the directory where the script is located
set "SCRIPT_DIR=%~dp0"

REM Check for Administrator privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Requesting administrative privileges...
    powershell -Command "Start-Process -Verb runAs -WorkingDirectory '%SCRIPT_DIR%' -FilePath '%~f0'"
    exit /b
)

REM Force working directory to script location
cd /d "%SCRIPT_DIR%"

REM Define Miniconda installation directory
set "CONDA_DIR=%USERPROFILE%\Miniconda3"

REM Update PATH environment variable for the current script
set "PATH=%CONDA_DIR%\Scripts;%CONDA_DIR%\Library\bin;%CONDA_DIR%\bin;%PATH%"

REM Read the environment name from environment.yml
for /f "tokens=2 delims=: " %%a in ('findstr /i "name:" "%SCRIPT_DIR%environment.yml"') do set "ENV_NAME=%%a"

REM Activate the environment
call "%CONDA_DIR%\Scripts\activate.bat" %ENV_NAME%

REM Set PYTHONUTF8=1 to enable UTF-8 encoding
set "PYTHONUTF8=1"

REM Define the environment variables
set "AYMURAI_CACHE_BASEPATH=%SCRIPT_DIR%cache\aymurai"
set "DISKCACHE_ROOT=%SCRIPT_DIR%cache\diskcache"
set "FLAIR_CACHE_ROOT=%SCRIPT_DIR%models\flair"
set "TFHUB_CACHE_DIR=%SCRIPT_DIR%models\tfhub"
set "SQLALCHEMY_DATABASE_URI=sqlite:///%SCRIPT_DIR%api\resources\cache\sqlite\database.db"
set "RESOURCES_BASEPATH=%SCRIPT_DIR%api\resources"
set "LIBREOFFICE_BIN=C:\\Program Files\\LibreOffice\\program\\soffice.exe"

REM Run the application 
call python -m uvicorn --app-dir=api main:api --reload --host=0.0.0.0 --port=8899
