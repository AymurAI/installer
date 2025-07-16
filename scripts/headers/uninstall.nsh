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
        nsExec::ExecToLog '"$INSTDIR\uninstall.bat" true'
        Goto end_miniconda

    skip_miniconda:
        ; Run the uninstallation batch file without Miniconda uninstallation flag
        nsExec::ExecToLog '"$INSTDIR\uninstall.bat" false'

    end_miniconda:
        ; Continue with the uninstallation process

    ; Remove registry keys
    DeleteRegKey HKLM "Software\${APP_NAME}"
    
    ; Remove installation directory and all its contents, including subdirectories
    RMDir /r /REBOOTOK "$INSTDIR"

    ; Remove desktop shortcuts
    Delete "$DESKTOP\${APP_NAME}.lnk"
!macroend
