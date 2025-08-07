; Uninstaller Header

; Define the source directory relative to the script directory
!define UNINST_SOURCE_DIR "..\resources"

!macro Uninstall
    ; Set output path
    SetOutPath $INSTDIR

    ; Copy uninstallation batch file
    File "${UNINST_SOURCE_DIR}\uninstall.bat"

    ; Uninstall Miniconda if selected by user
    ${If} $UNINSTALL_MINICONDA = 1
        nsExec::ExecToLog '"$INSTDIR\uninstall.bat" true'
    ${Else}
        nsExec::ExecToLog '"$INSTDIR\uninstall.bat" false'
    ${EndIf}

    ; Remove registry keys
    DeleteRegKey HKLM "Software\${APP_NAME}"
    DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}"
    
    ; Remove installation directory and all its contents, including subdirectories
    RMDir /r /REBOOTOK "$INSTDIR"

    ; Remove desktop shortcuts
    Delete "$DESKTOP\${APP_NAME}.lnk"
    Delete "$SMPROGRAMS\${APP_NAME}.lnk"
!macroend
