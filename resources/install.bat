@echo off
REM Define the directory where the script is located
set "SCRIPT_DIR=%~dp0"

REM Define Miniconda installation directory
if not defined CONDA_DIR (
    set "CONDA_DIR=%USERPROFILE%\Miniconda3"
)

REM Define Miniconda installer file path
set "CONDA_INSTALLER=%SCRIPT_DIR%Miniconda3-py312_24.7.1-0-Windows-x86_64.exe"

REM Check if Miniconda is already installed
if exist "%CONDA_DIR%" (
    echo Miniconda is already installed.
) else (
    REM Install Miniconda silently
    echo Installing Miniconda...
    call "%CONDA_INSTALLER%" /InstallationType=JustMe /AddToPath=0 /RegisterPython=0 /S /D=%CONDA_DIR%
    if errorlevel 1 (
        echo Miniconda installation failed.
        exit /b 1
    )
    echo Miniconda installed.
)

REM Update PATH environment variable for the current script
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

REM Check if the Conda environment already exists
call conda env list | findstr %ENV_NAME% >nul
if errorlevel 1 (
    REM Create the Conda environment
    echo Creating Conda environment '%ENV_NAME%'...
    call "%CONDA_DIR%\Scripts\conda.exe" env create -f "%SCRIPT_DIR%environment.yml" -y
    
    REM Activate the environment
    call "%CONDA_DIR%\Scripts\activate.bat" %ENV_NAME%

    REM Workaround to fix python-magic issue
    REM https://github.com/ahupp/python-magic/issues/248
    call pip uninstall -y python-magic
    call pip install python-magic==0.4.27
    call pip install python-magic-bin==0.4.14

    REM Check if libmagic path is already in the PATH environment variable
    powershell -Command "if (-not $env:PATH.Contains('magic\libmagic')) { Write-Host 'libmagic path not found in PATH, adding it...'; $sitePackages = (Get-ChildItem -Path (Get-Command python).Source).Directory.Parent.FullName + '\aymurai-backend\Lib\site-packages'; $libmagicPath = Join-Path -Path $sitePackages -ChildPath 'magic\libmagic'; [System.Environment]::SetEnvironmentVariable('PATH', $env:PATH + ';' + $libmagicPath, [System.EnvironmentVariableTarget]::User); Write-Host 'libmagic path added to PATH.' } else { Write-Host 'libmagic path already exists in PATH.' }"

    REM Install Spacy's Spanish model
    call python -m spacy download es_core_news_sm

    if errorlevel 1 (
        echo Conda environment creation failed.
        exit /b 1
    ) else (
        echo Conda environment '%ENV_NAME%' created successfully.
    )
) else (
    echo Conda environment '%ENV_NAME%' already exists.
)

REM Create the api resources directory if it doesn't exist
if not exist "%SCRIPT_DIR%api\resources" (
    mkdir "%SCRIPT_DIR%api\resources"
)

REM Move pipelines and static directories to the api directory
move "%SCRIPT_DIR%pipelines" "%SCRIPT_DIR%api\resources\pipelines"
move "%SCRIPT_DIR%static" "%SCRIPT_DIR%api\resources\static"

REM Download the api module from the repository
curl --ssl-no-revoke -o "%SCRIPT_DIR%api\__init__.py" -O https://raw.githubusercontent.com/AymurAI/backend/refs/heads/dev/aymurai/api/__init__.py
curl --ssl-no-revoke -o "%SCRIPT_DIR%api\main.py" -O https://raw.githubusercontent.com/AymurAI/backend/refs/heads/dev/aymurai/api/main.py

REM Patch the main.py file to properly run on Windows
call patch --verbose api\main.py < api_changes.patch

REM Create the models directory if it doesn't exist
if not exist "%SCRIPT_DIR%models" (
    mkdir "%SCRIPT_DIR%models"
)

REM Activate the environment
call "%CONDA_DIR%\Scripts\activate.bat" %ENV_NAME%

REM Define the cache directories
set "AYMURAI_CACHE_BASEPATH=%SCRIPT_DIR%cache\aymurai"
set "DISKCACHE_ROOT=%SCRIPT_DIR%cache\diskcache"
set "FLAIR_CACHE_ROOT=%SCRIPT_DIR%models\flair"
set "TFHUB_CACHE_DIR=%SCRIPT_DIR%models\tfhub"

REM Run the api main.py file to download the models
call python "%SCRIPT_DIR%api\main.py"

REM Deactivate the environment
call conda deactivate

REM Exit the script
echo Backend dependencies installed successfully.
exit /b 0
