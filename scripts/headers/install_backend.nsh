; Back-End Installation Header

; Define the source directory relative to the script directory
!define SOURCE_DIR "..\resources"

!macro InstallBackEnd
    ; Set output path
    SetOutPath $INSTDIR

    ; Copy installation files
    File "${SOURCE_DIR}\Miniconda3-py312_24.7.1-0-Windows-x86_64.exe"
    File "${SOURCE_DIR}\LibreOffice_24.8.2_Win_x86-64.msi"
    File "${SOURCE_DIR}\aymurai-1.1.0-py3-none-any.whl"
    File "${SOURCE_DIR}\environment.yml"
    File "${SOURCE_DIR}\install.bat"
    File "${SOURCE_DIR}\run_server.bat"
    File "${SOURCE_DIR}\run_client_server.bat"
    File "${SOURCE_DIR}\api_changes.patch"
    File /r "${SOURCE_DIR}\api\*.*"

    ; Run the installation batch file
    DetailPrint "Installing backend dependencies..."
    ExecWait '"$INSTDIR\install.bat"' $0

    ; Install LibreOffice silently in the installation directory
    nsExec::ExecToLog 'msiexec /i "$INSTDIR\LibreOffice_24.8.2_Win_x86-64.msi" /qn'

    ; Add 'es-AR' locale and set 'en-US' as default
    nsExec::ExecToLog 'powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-WinSystemLocale"'
    nsExec::ExecToLog 'powershell -NoProfile -ExecutionPolicy Bypass -Command "Set-WinSystemLocale -SystemLocale \"en-US\""'
    nsExec::ExecToLog 'powershell -NoProfile -ExecutionPolicy Bypass -Command "Set-WinUILanguageOverride -Language \"es-AR\""'
    nsExec::ExecToLog 'powershell -NoProfile -ExecutionPolicy Bypass -Command "Set-WinUserLanguageList \"es-AR\" -Force"'
    nsExec::ExecToLog 'powershell -NoProfile -ExecutionPolicy Bypass -Command "$env:LANG = \"en-US.UTF-8\"; $env:LC_ALL = \"en-US.UTF-8\""'
    nsExec::ExecToLog 'powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-WinUserLanguageList"'
    nsExec::ExecToLog 'powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-Culture"'

    ${If} $0 != 0
        MessageBox MB_OK|MB_ICONEXCLAMATION "Back-End Installation failed. Please try again."
        Abort
    ${Else}
        ; Remove installation files
        DetailPrint "Removing installation files..."
        Delete "$INSTDIR\Miniconda3-py312_24.7.1-0-Windows-x86_64.exe"
        Delete "$INSTDIR\LibreOffice_24.8.2_Win_x86-64.msi"
        Delete "$INSTDIR\aymurai-1.1.0-py3-none-any.whl"
        Delete "$INSTDIR\install.bat"
        Delete "$INSTDIR\api_changes.patch"

        DetailPrint "Back-End Installation successful."
    ${EndIf}

    ; Write installation path to registry
    WriteRegStr HKLM "Software\${APP_NAME}" "Install_Dir" "$INSTDIR"
!macroend
