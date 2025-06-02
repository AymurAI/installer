; Back-End Installation Header

; Define the source directory relative to the script directory
!define SOURCE_DIR "..\resources"

!macro InstallBackEnd
    ; Set output path
    SetOutPath $INSTDIR

    ; Copy installation files
    File "${SOURCE_DIR}\Miniconda3-py312_24.7.1-0-Windows-x86_64.exe"
    File "${SOURCE_DIR}\LibreOffice_25.2.2_Win_x86-64.msi"
    File "${SOURCE_DIR}\aymurai-1.1.1-py3-none-any.whl"
    File "${SOURCE_DIR}\environment.yml"
    File "${SOURCE_DIR}\install.bat"
    File "${SOURCE_DIR}\run_server.bat"
    File "${SOURCE_DIR}\output_limit.vbs"
    File /r "${SOURCE_DIR}\api\*.*"

    ; Install LibreOffice silently in the installation directory
    DetailPrint "Installing LibreOffice..."
    nsExec::ExecToLog 'msiexec /i "$INSTDIR\LibreOffice_25.2.2_Win_x86-64.msi" /qn'
    DetailPrint "LibreOffice installation completed."

    ; Run the installation batch file
    DetailPrint "Installing backend dependencies..."
    nsExec::ExecToLog '"cscript.exe" //NOLOGO output_limit.vbs "$INSTDIR\install.bat"'
    
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
    Delete "$INSTDIR\Miniconda3-py312_24.7.1-0-Windows-x86_64.exe"
    Delete "$INSTDIR\LibreOffice_25.2.2_Win_x86-64.msi"
    Delete "$INSTDIR\aymurai-1.1.1-py3-none-any.whl"
    Delete "$INSTDIR\install.bat"

    ; Write installation path to registry
    WriteRegStr HKLM "Software\${APP_NAME}" "Install_Dir" "$INSTDIR"

    DetailPrint "Back-End Installation successful."
!macroend
