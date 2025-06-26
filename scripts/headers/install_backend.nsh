; Backend Installation Header

; Define the source directory relative to the script directory
!define SOURCE_DIR "..\resources"

!macro InstallBackend
    ; Set output path
    SetOutPath $INSTDIR

    ; Copy installation files
    File "${SOURCE_DIR}\aymurai-1.1.11-py3-none-any.whl"
    File "${SOURCE_DIR}\environment.yml"
    File "${SOURCE_DIR}\install.bat"
    File "${SOURCE_DIR}\run_server.bat"
    File /r "${SOURCE_DIR}\api\*.*"

    ; Run the installation batch file
    DetailPrint "Installing backend dependencies..."
    nsExec::Exec '"$INSTDIR\install.bat"'
    
    ; Add 'es-AR' locale and set 'en-US' as default
    nsExec::ExecToLog 'powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-WinSystemLocale"'
    nsExec::ExecToLog 'powershell -NoProfile -ExecutionPolicy Bypass -Command "Set-WinSystemLocale -SystemLocale \"en-US\""'
    nsExec::ExecToLog 'powershell -NoProfile -ExecutionPolicy Bypass -Command "Set-WinUILanguageOverride -Language \"es-AR\""'
    nsExec::ExecToLog 'powershell -NoProfile -ExecutionPolicy Bypass -Command "Set-WinUserLanguageList \"es-AR\" -Force"'
    nsExec::ExecToLog 'powershell -NoProfile -ExecutionPolicy Bypass -Command "$env:LANG = \"en-US.UTF-8\"; $env:LC_ALL = \"en-US.UTF-8\""'
    nsExec::ExecToLog 'powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-WinUserLanguageList"'
    nsExec::ExecToLog 'powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-Culture"'

    ; Remove installation files
    DetailPrint "Removing installation files..."
    Delete "$INSTDIR\aymurai-1.1.11-py3-none-any.whl"
    Delete "$INSTDIR\install.bat"

    ; Write installation path to registry
    WriteRegStr HKLM "Software\${APP_NAME}" "Install_Dir" "$INSTDIR"

    DetailPrint "Backend installation successful."
!macroend
