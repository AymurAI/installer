@echo off
REM Define the directory where the script is located
set "SCRIPT_DIR=%~dp0"

REM Force working directory to script location
cd /d "%SCRIPT_DIR%"

REM Define Miniconda installation directory
set "CONDA_DIR=%USERPROFILE%\miniconda3"

REM Update PATH environment variable for the current script
set "PATH=%CONDA_DIR%\Scripts;%CONDA_DIR%\Library\bin;%CONDA_DIR%\bin;%PATH%"

REM Read the environment name from environment.yml
for /f "tokens=2 delims=: " %%a in ('findstr /i "name:" "%SCRIPT_DIR%environment.yml"') do set "ENV_NAME=%%a"

REM Activate the environment
call "%CONDA_DIR%\Scripts\activate.bat" %ENV_NAME%

REM Set PYTHONUTF8=1 to enable UTF-8 encoding
set "PYTHONUTF8=1"

REM Ensure LOCALAPPDATA is defined and establish a writable data root
if not defined LOCALAPPDATA (
    echo Error: LOCALAPPDATA environment variable is not defined.
    exit /b 1
)
set "AYMURAI_DATA_DIR=%LOCALAPPDATA%\AymurAI"
set "AYMURAI_CACHE_BASEPATH=%AYMURAI_DATA_DIR%\cache\aymurai"
set "DISKCACHE_ROOT=%AYMURAI_DATA_DIR%\cache\diskcache"
set "FLAIR_CACHE_ROOT=%AYMURAI_DATA_DIR%\models\flair"
set "TFHUB_CACHE_DIR=%AYMURAI_DATA_DIR%\models\tfhub"
set "AYMURAI_SQLITE_DIR=%AYMURAI_DATA_DIR%\data\sqlite"
set "AYMURAI_DATABASE_FILE=%AYMURAI_SQLITE_DIR%\database.db"
set "AYMURAI_LOG_DIR=%AYMURAI_DATA_DIR%\logs"
set "AYMURAI_LOG_FILE=%AYMURAI_LOG_DIR%\backend.log"
set "AYMURAI_TRAY_ICON=%SCRIPT_DIR%\api\resources\api\static\logo256-text.ico"

for %%D in (
    "%AYMURAI_DATA_DIR%"
    "%AYMURAI_DATA_DIR%\cache"
    "%AYMURAI_CACHE_BASEPATH%"
    "%DISKCACHE_ROOT%"
    "%AYMURAI_DATA_DIR%\models"
    "%FLAIR_CACHE_ROOT%"
    "%TFHUB_CACHE_DIR%"
    "%AYMURAI_DATA_DIR%\data"
    "%AYMURAI_SQLITE_DIR%"
    "%AYMURAI_LOG_DIR%"
) do (
    if not exist "%%~D" mkdir "%%~D"
)

REM Define the environment variables consumed by the backend
set "RESOURCES_BASEPATH=%SCRIPT_DIR%api\resources"
set "SQLALCHEMY_DATABASE_URI=sqlite:///%AYMURAI_DATABASE_FILE:\=/%%"
set "LIBREOFFICE_BIN=C:\Program Files\LibreOffice\program\soffice.exe"

REM Run the tray launcher that manages the backend process
call python "%SCRIPT_DIR%tray_runner.py"
