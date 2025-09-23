@echo off
REM Define the directory where the script is located
set "SCRIPT_DIR=%~dp0"

REM Define Miniconda installation directory
if not defined CONDA_DIR (
    set "CONDA_DIR=%USERPROFILE%\miniconda3"
)

REM Define the writable application data directory under the current user profile
if not defined LOCALAPPDATA (
    echo Error: LOCALAPPDATA environment variable is not defined.
    exit /b 1
)
set "AYMURAI_DATA_DIR=%LOCALAPPDATA%\AymurAI"

REM Check if Miniconda is already installed
if exist "%CONDA_DIR%" (
    echo Miniconda is already installed.
) else (
    echo Miniconda is not installed. Please install it first and try again.
    exit /b 1
)

REM Update PATH environment variable for the current script
setlocal
set "PATH=%CONDA_DIR%\Scripts;%CONDA_DIR%\Library\bin;%CONDA_DIR%\bin;%PATH%"

REM Check if Conda executable exists
if not exist "%CONDA_DIR%\Scripts\conda.exe" (
    echo Conda executable not found. Initialization failed.
    exit /b 1
) else (
    echo Conda executable found.
)

REM Read the environment name from environment.yml
for /f "tokens=2 delims=: " %%a in ('findstr /i "name:" "%SCRIPT_DIR%environment.yml"') do set "ENV_NAME=%%a"

REM Ensure ENV_NAME is set
if not defined ENV_NAME (
    echo Environment name not found in environment.yml.
    exit /b 1
)
REM Check if the Conda environment creation completed
if not exist "%SCRIPT_DIR%full_env" (
    REM Check if the Conda environment already exists
    call conda env list | findstr %ENV_NAME% >nul
    if errorlevel 1 (
        REM Create the Conda environment
        echo Creating Conda environment '%ENV_NAME%'...
        set "PIP_EXISTS_ACTION=w"
        REM Set the CONDA_PLUGINS_AUTO_ACCEPT_TOS variable to yes to avoid TOS prompts
        REM https://github.com/scikit-learn/scikit-learn/issues/31773#issuecomment-3085583618
        set "CONDA_PLUGINS_AUTO_ACCEPT_TOS=yes"
        call "%CONDA_DIR%\Scripts\conda.exe" env create -f "%SCRIPT_DIR%environment.yml" -y
        if errorlevel 1 (
            echo Conda environment creation failed.
            exit /b 1
        )
        REM Activate the environment
        call "%CONDA_DIR%\Scripts\activate.bat" %ENV_NAME%
    ) else (
        echo Updating Conda environment '%ENV_NAME%'...
        REM Activate the environment
        call "%CONDA_DIR%\Scripts\activate.bat" %ENV_NAME%
        set "PIP_EXISTS_ACTION=w"
        REM Update the conda environment
        call "%CONDA_DIR%\Scripts\conda.exe" env update -f "%SCRIPT_DIR%environment.yml"
        if errorlevel 1 (
            echo Conda environment update failed.
            exit /b 1
        )
    )
    
    REM Instal forked version of textract to fix this issue
    REM https://github.com/deanmalmgren/textract/issues/313
    call pip uninstall -y textract
    if errorlevel 1 (
        echo Conda environment creation failed.
        exit /b 1
    )
    call pip install "textract @ git+https://github.com/MaxEtMoritz/textract@master"

    if errorlevel 1 (
        echo Conda environment creation failed.
        exit /b 1
    ) else (
        echo Conda environment '%ENV_NAME%' created successfully.
        call echo yes > "%SCRIPT_DIR%full_env"
    )
) else (
    REM Check if the conda environment actually exists
    call conda env list | findstr %ENV_NAME% >nul
    if errorlevel 1 (
        echo full_env file exists but conda environment '%ENV_NAME%' is missing. Recreating environment...
        del "%SCRIPT_DIR%full_env"
        REM Re-run this script to trigger environment creation
        call "%~f0"
        exit /b %ERRORLEVEL%
    )
    echo Conda environment '%ENV_NAME%' already exists and is complete.
    REM Activate the environment
    call "%CONDA_DIR%\Scripts\activate.bat" %ENV_NAME%
)

REM Create the api resources directory if it doesn't exist
if not exist "%SCRIPT_DIR%api\resources\api" (
    mkdir "%SCRIPT_DIR%api\resources\api"
)

REM Move pipelines and static directories to the api directory
if not exist "%SCRIPT_DIR%api\resources\pipelines" (
    move "%SCRIPT_DIR%pipelines" "%SCRIPT_DIR%api\resources\pipelines"
) else (
    if exist "%SCRIPT_DIR%pipelines" (
        rmdir /s /q "%SCRIPT_DIR%pipelines"
    )
)
if not exist "%SCRIPT_DIR%api\resources\api\static" (
    move "%SCRIPT_DIR%static" "%SCRIPT_DIR%api\resources\api\static"
) else (
    if exist "%SCRIPT_DIR%static" (
        rmdir /s /q "%SCRIPT_DIR%static"
    )
)

REM Download the api module from the repository
if not exist "%SCRIPT_DIR%api\__init__.py" (
    curl --ssl-no-revoke -o "%SCRIPT_DIR%api\__init__.py" https://raw.githubusercontent.com/AymurAI/backend/refs/heads/dev/aymurai/api/__init__.py
)
if not exist "%SCRIPT_DIR%api\main.py" (
    curl --ssl-no-revoke -o "%SCRIPT_DIR%api\main.py" https://raw.githubusercontent.com/AymurAI/backend/refs/heads/dev/aymurai/api/main.py
)

REM Prepare writable cache/model/data directories under LOCALAPPDATA
set "AYMURAI_CACHE_BASEPATH=%AYMURAI_DATA_DIR%\cache\aymurai"
set "DISKCACHE_ROOT=%AYMURAI_DATA_DIR%\cache\diskcache"
set "FLAIR_CACHE_ROOT=%AYMURAI_DATA_DIR%\models\flair"
set "TFHUB_CACHE_DIR=%AYMURAI_DATA_DIR%\models\tfhub"
set "AYMURAI_SQLITE_DIR=%AYMURAI_DATA_DIR%\data\sqlite"
set "AYMURAI_DATABASE_FILE=%AYMURAI_SQLITE_DIR%\database.db"

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
) do (
    if not exist "%%~D" mkdir "%%~D"
)

REM Define the RESOURCES_BASEPATH environment variable
set "RESOURCES_BASEPATH=%SCRIPT_DIR%api\resources"

REM Point SQLAlchemy to the writable SQLite database location (convert backslashes to forward slashes)
set "SQLALCHEMY_DATABASE_URI=sqlite:///%AYMURAI_DATABASE_FILE:\=/%%"

REM Run the api main.py file to download the models
call python "%SCRIPT_DIR%api\main.py"
if errorlevel 1 (
    echo Error: Failed to run api\main.py. See above for details.
    exit /b 1
) else (
    REM Exit the script
    echo Backend dependencies installed successfully.
    exit /b 0
)
