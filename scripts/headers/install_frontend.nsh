; Front-End Installation Header

!define FRONTEND_URL "https://github.com/AymurAI/desktop-app/releases/download/1.12.0/AymurAI-V.1.12.0.zip"

!macro InstallFrontend
    ; Check if front-end is already installed
    IfFileExists "$INSTDIR\${APP_NAME}.exe" frontend_skip_download frontend_download

    frontend_skip_download:
        DetailPrint "Front-end is already installed."
        Goto finish

    frontend_download:
        DetailPrint "Downloading front-end..."

        ; Set output path
        SetOutPath $INSTDIR

        ; Download ZIP from GitHub
        ExecWait 'powershell -Command "Invoke-WebRequest -Uri ${FRONTEND_URL} -OutFile \"$INSTDIR\${APP_NAME}.zip\""'
        
        ; Unzip downloaded file
        ExecWait 'powershell -Command "Expand-Archive -Path \"$INSTDIR\${APP_NAME}.zip\" -DestinationPath \"$INSTDIR\" -Force"'
        
        ; Remove ZIP file after extraction
        Delete "$INSTDIR\${APP_NAME}.zip"

        ; Find the subdirectory containing the executable
        ClearErrors
        FindFirst $R0 $R1 "$INSTDIR\*.*" ; Find the first file/folder in $INSTDIR
        loop:
            IfErrors done_find ; If there are no more items, exit the loop
            IfFileExists "$INSTDIR\$R1\${APP_NAME}.exe" 0 skip ; Check if $R1 is a directory containing the executable
            StrCpy $R2 "$R1" ; Save the directory name in $R2
            Goto done_find ; We found the directory, so we can exit the loop

        skip:
            FindNext $R0 $R1 ; Find the next file/folder
            Goto loop

        done_find:
            FindClose $R0

        ; Move files from the found subdirectory to the parent installation folder
        IfFileExists "$INSTDIR\$R2\*.*" 0 +2
        CopyFiles "$INSTDIR\$R2\*.*" "$INSTDIR"

        ; Remove the now-empty subdirectory
        RMDir /r "$INSTDIR\$R2"

        ; Check if the executable is now present in the installation directory
        IfFileExists "$INSTDIR\${APP_NAME}.exe" frontend_success frontend_fail

        frontend_fail:
            MessageBox MB_OK|MB_ICONEXCLAMATION "Front-End Installation failed. Please try again."
            Abort
        
        frontend_success:
            DetailPrint "Front-End Installation successful."
        
    finish:
        ; No further actions needed here
!macroend
