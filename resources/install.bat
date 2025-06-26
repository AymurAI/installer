@echo off
REM Define the directory where the script is located
set "SCRIPT_DIR=%~dp0"

REM Define Miniconda installation directory
if not defined CONDA_DIR (
    set "CONDA_DIR=%USERPROFILE%\miniconda3"
)

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
if not exist "%SCRIPT_DIR%full_env"  (
    REM Check if the Conda environment already exists
    call conda env list | findstr %ENV_NAME% >nul
    if errorlevel 1 (
        REM Create the Conda environment
        echo Creating Conda environment '%ENV_NAME%'...
        set "PIP_EXISTS_ACTION=w"
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
        REM Update the conda enviroment
        call "%CONDA_DIR%\Scripts\conda.exe" env update -f "%SCRIPT_DIR%environment.yml"
        if errorlevel 1 (
            echo Conda environment update failed.
            exit /b 1
        )
    )
    
    REM Workaround to fix python-magic issue
    REM https://github.com/ahupp/python-magic/issues/248
    call pip uninstall -y python-magic
    if errorlevel 1 (
        echo Conda environment creation failed.
        exit /b 1
    )

    call pip install python-magic==0.4.27
    if errorlevel 1 (
        echo Conda environment creation failed.
        exit /b 1
    )
    call pip install python-magic-bin==0.4.14
    if errorlevel 1 (
        echo Conda environment creation failed.
        exit /b 1
    )

    REM Check if libmagic path is already in the PATH environment variable
    powershell -Command "if (-not $env:PATH.Contains('magic\libmagic')) { Write-Host 'libmagic path not found in PATH, adding it...'; $sitePackages = (Get-ChildItem -Path (Get-Command python).Source).Directory.Parent.FullName + '\aymurai-backend\Lib\site-packages'; $libmagicPath = Join-Path -Path $sitePackages -ChildPath 'magic\libmagic'; [System.Environment]::SetEnvironmentVariable('PATH', $env:PATH + ';' + $libmagicPath, [System.EnvironmentVariableTarget]::User); Write-Host 'libmagic path added to PATH.' } else { Write-Host 'libmagic path already exists in PATH.' }"
    if errorlevel 1 (
        echo Conda environment creation failed.
        exit /b 1
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
    echo Conda environment '%ENV_NAME%' already exists and is complete.
    REM Activate the environment
    call "%CONDA_DIR%\Scripts\activate.bat" %ENV_NAME%
)

REM Create the api resources directory if it doesn't exist
if not exist "%SCRIPT_DIR%api\resources\api" (
    mkdir "%SCRIPT_DIR%api\resources\api"
)

REM Move pipelines and static directories to the api directory
if exist "%SCRIPT_DIR%pipelines" (
    move "%SCRIPT_DIR%pipelines" "%SCRIPT_DIR%api\resources\pipelines"
)
if exist "%SCRIPT_DIR%static" (
    move "%SCRIPT_DIR%static" "%SCRIPT_DIR%api\resources\api\static"
)

REM Download the api module from the repository
if not exist "%SCRIPT_DIR%api\__init__.py" (
    curl --ssl-no-revoke -o "%SCRIPT_DIR%api\__init__.py" https://raw.githubusercontent.com/AymurAI/backend/refs/heads/dev/aymurai/api/__init__.py
)
if not exist "%SCRIPT_DIR%api\main.py" (
    curl --ssl-no-revoke -o "%SCRIPT_DIR%api\main.py" https://raw.githubusercontent.com/AymurAI/backend/refs/heads/dev/aymurai/api/main.py
)

REM Define the cache directories
set "AYMURAI_CACHE_BASEPATH=%SCRIPT_DIR%cache\aymurai"
set "DISKCACHE_ROOT=%SCRIPT_DIR%cache\diskcache"
set "FLAIR_CACHE_ROOT=%SCRIPT_DIR%models\flair"
set "TFHUB_CACHE_DIR=%SCRIPT_DIR%models\tfhub"

REM Define the RESOURCES_BASEPATH environment variable
set "RESOURCES_BASEPATH=%SCRIPT_DIR%api\resources"

REM Run the api main.py file to download the models
call python "%SCRIPT_DIR%api\main.py"

REM Exit the script
echo Backend dependencies installed successfully.
exit /b 0
