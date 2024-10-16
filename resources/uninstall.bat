@echo off
REM Define the directory where the script is located
set "SCRIPT_DIR=%~dp0"

REM Miniconda uninstallation boolean
set "UNINSTALL_MINICONDA=%1"

REM Define Miniconda installation directory
set "CONDA_DIR=%USERPROFILE%\Miniconda3"

REM Read the environment name from environment.yml
for /f "tokens=2 delims=: " %%a in ('findstr /i "name:" "%SCRIPT_DIR%environment.yml"') do set "ENV_NAME=%%a"
echo Removing Conda environment '%ENV_NAME%'...

REM Remove the Conda environment
call "%CONDA_DIR%\Scripts\conda.exe" remove -n %ENV_NAME% --all -y || (
    echo Failed to remove Conda environment.
)
echo Conda environment '%ENV_NAME%' removed.

REM Check if Miniconda should be uninstalled
if "%UNINSTALL_MINICONDA%" == "true" (
    REM Uninstall Miniconda
    echo Uninstalling Miniconda...
    call "%CONDA_DIR%\Uninstall-Miniconda3.exe" /S    
    echo Miniconda uninstallation complete.
) else (
    echo Miniconda will not be uninstalled.
)

exit /b 0
