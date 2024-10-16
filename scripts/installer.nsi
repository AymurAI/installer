; Main Installer Script

!define APP_NAME "AymurAI"
!define APP_VERSION "1.0"
!define OUTPUT_DIR "..\build"

; Installer Information
Name "${APP_NAME} v${APP_VERSION}"
OutFile "${OUTPUT_DIR}\${APP_NAME}-Installer.exe"

; Request application privileges
RequestExecutionLevel admin

; The default installation directory
InstallDir $DOCUMENTS\${APP_NAME}

; Registry key to store the installation directory
InstallDirRegKey HKLM "Software\${APP_NAME}" "Install_Dir"

; Include necessary headers
!include "FileFunc.nsh"
!include "LogicLib.nsh"
; !include "MUI2.nsh"

; Include custom headers
!include "headers\install_backend.nsh"
!include "headers\install_frontend.nsh"
!include "headers\uninstall.nsh"

;--------------------------------

; Pages
Page components
Page directory
Page instfiles

UninstPage uninstConfirm
UninstPage instfiles

;--------------------------------

Section "Back-End"
    ; Execute custom .nsh headers for back-end setup
    !insertmacro InstallBackend
SectionEnd

Section "Front-End"
    ; Execute custom .nsh headers for front-end setup
    !insertmacro InstallFrontend
SectionEnd

Section "Desktop shortcuts"
    ; Create a shortcut on the desktop to the client executable
    CreateShortCut "$DESKTOP\${APP_NAME}-Client.lnk" "$INSTDIR\${APP_NAME}.exe"
    
    ; Create a shortcut on the desktop to the server executable
    CreateShortCut "$DESKTOP\${APP_NAME}-Server.lnk" "$INSTDIR\run_server.bat" "" "$INSTDIR\api\resources\static\logo256-text.ico"
    
    ; Create a shortcut on the desktop to both the server and the client executables
    CreateShortCut "$DESKTOP\${APP_NAME}-Client-Server.lnk" "$INSTDIR\run_client_server.bat"  "" "$INSTDIR\api\resources\static\logo256-text.ico"
SectionEnd

Section "Uninstaller"
    ; Create uninstaller
    WriteUninstaller "$INSTDIR\Uninstall.exe"
SectionEnd

;--------------------------------

Section "Uninstall"
    ; Execute custom .nsh headers for uninstallation
    !insertmacro Uninstall
SectionEnd
