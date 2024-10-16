; Uninstaller Header

; Define the source directory relative to the script directory
!define UNINST_SOURCE_DIR "..\resources"

!macro Uninstall
    ; Set output path
    SetOutPath $INSTDIR

    ; Copy uninstallation batch file
    File "${UNINST_SOURCE_DIR}\uninstall.bat"
    
    ; Prompt user to uninstall Miniconda
    MessageBox MB_YESNO|MB_ICONQUESTION "Do you want to uninstall Miniconda?" IDYES uninstall_miniconda IDNO skip_miniconda

    uninstall_miniconda:
        ; Run the uninstallation batch file with Miniconda uninstallation flag
        ExecWait '"$INSTDIR\uninstall.bat" true'
        
    skip_miniconda:
        ; Run the uninstallation batch file without Miniconda uninstallation flag
        ExecWait '"$INSTDIR\uninstall.bat" false'

    ; Prompt user to uninstall LibreOffice
    MessageBox MB_YESNO|MB_ICONQUESTION "Do you want to uninstall LibreOffice?" IDYES uninstall_libreoffice IDNO skip_libreoffice

    uninstall_libreoffice:
        ; Uninstall LibreOffice
        ; NOTE: The GUID is unique to the installed version of LibreOffice
        nsExec::ExecToLog 'msiexec /x "{2B5B0425-12C7-4D48-ACA8-38CCA3082A81}" /qn /norestart'
    
    skip_libreoffice:
        ; Continue with the uninstallation process
    
    ; Delete uninstaller
    Delete "$INSTDIR\Uninstall.exe"

    ; Remove registry keys
    DeleteRegKey HKLM "Software\${APP_NAME}"
    
    ; Remove resources directory and all its contents
    RMDir /r "$INSTDIR\resources"

    ; Check if the directory still exists
    IfFileExists "$INSTDIR\resources\*.*" 0 force

    force:
        ; If the directory still exists, use an elevated command to forcefully remove it
        Exec '"$SYSDIR\cmd.exe" /C "rmdir /S /Q \"$INSTDIR\resources\""'
    
    ; Remove installation directory and all its contents, includind subdirectories
    RMDir /r "$INSTDIR"

    ; Remove desktop shortcuts
    Delete "$DESKTOP\${APP_NAME}-Client.lnk"
    Delete "$DESKTOP\${APP_NAME}-Server.lnk"
    Delete "$DESKTOP\${APP_NAME}-Client-Server.lnk"
!macroend
