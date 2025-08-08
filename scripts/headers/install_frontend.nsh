; Frontend Installation Header

!define FRONTEND_URL "https://github.com/AymurAI/desktop-app/releases/download/1.20.2/AymurAI-win32-x64-1-20-2.zip"
!define ARCHIVO_FONT "..\resources\Archivo-Regular.ttf"

!macro InstallFrontend
    ; Check if frontend is already installed
    IfFileExists "$INSTDIR\${APP_NAME}.exe" frontend_skip_download frontend_download

    frontend_skip_download:
        DetailPrint "Frontend is already installed."
        Goto install_archivo_font

    frontend_download:
        ; Set output path
        SetOutPath $INSTDIR

        ; Download ZIP from GitHub
        DetailPrint "Downloading frontend..."
        nsExec::ExecToLog 'powershell -Command "Invoke-WebRequest -Uri ${FRONTEND_URL} -OutFile \"$INSTDIR\${APP_NAME}.zip\""'
        
        ; Unzip downloaded file
        DetailPrint "Extracting frontend..."
        nsExec::ExecToLog 'powershell -Command "Expand-Archive -Path \"$INSTDIR\${APP_NAME}.zip\" -DestinationPath \"$INSTDIR\" -Force"'
        
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
            MessageBox MB_OK|MB_ICONEXCLAMATION "Frontend installation failed. Please try again."
            Abort
        
        frontend_success:
            DetailPrint "Frontend installation successful."

    install_archivo_font:
        ; Check if any Archivo font already exists in Windows Fonts
        nsExec::ExecToStack 'powershell -NoProfile -ExecutionPolicy Bypass -Command "$props = (Get-ItemProperty -Path \"HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts\").PSObject.Properties.Name | Where-Object { $_ -like \"Archivo*\" }; if ($props) { exit 0 } else { exit 1 }"'
        Pop $0
        StrCmp $0 "0" finish archivo_font_install

        archivo_font_install:
            ; Copy Archivo font file
            DetailPrint "Installing Archivo font..."
            SetOutPath $INSTDIR
            File "${ARCHIVO_FONT}"

            ; Copy Archivo font file to Windows Fonts
            nsExec::ExecToLog 'powershell -NoProfile -ExecutionPolicy Bypass -Command "Copy-Item -Path \"$INSTDIR\Archivo-Regular.ttf\" -Destination \"C:\Windows\Fonts\" -Force"'
            
            ; Add registry entry for the font
            nsExec::ExecToLog 'powershell -NoProfile -ExecutionPolicy Bypass -Command "New-ItemProperty -Path \"HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts\" -Name \"Archivo (TrueType)\" -PropertyType String -Value \"Archivo-Regular.ttf\" -Force"'
            DetailPrint "Archivo font installed successfully."
            
            ; Remove Archivo font file
            DetailPrint "Removing temporary Archivo font file..."
            Delete "$INSTDIR\Archivo-Regular.ttf"

    finish:
        ; No further actions needed here
!macroend
