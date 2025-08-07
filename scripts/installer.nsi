; Main Installer Script
Unicode true
ManifestDPIAware true

!define APP_NAME "AymurAI"
!define APP_VERSION "1.1"
!define OUTPUT_DIR "..\build"

; Installer Information
Name "${APP_NAME} v${APP_VERSION}"
OutFile "${OUTPUT_DIR}\${APP_NAME}-Installer.exe"
BrandingText "DataGenero - Collective AI"

; Request application privileges
RequestExecutionLevel admin

; The default installation directory
InstallDir $PROGRAMFILES64\${APP_NAME}

; Registry key to store the installation directory
InstallDirRegKey HKLM "Software\${APP_NAME}" "Install_Dir"

; Include necessary headers
!include "FileFunc.nsh"
!include "LogicLib.nsh"

; Include custom headers
!include "headers\install_backend.nsh"
!include "headers\install_frontend.nsh"
!include "headers\uninstall.nsh"

; Modern interface settings
!include "MUI2.nsh"

!define MUI_ICON "..\resources\api\static\logo256-text.ico"
!define MUI_HEADERIMAGE_BITMAP "..\resources\header.bmp"
!define MUI_WELCOMEFINISHPAGE_BITMAP "..\resources\banner.bmp"

!define MUI_WELCOMEPAGE_TEXT "This setup will guide you through the installation of ${APP_NAME} on your system.$\r$\n$\r$\nIt is recommended that you close all other applications before starting.$\r$\n$\r$\nMake sure you have LibreOffice and Miniconda installed on your system, as they are required for ${APP_NAME} to function properly.$\r$\n$\r$\nClick Next to continue."

!define MUI_HEADERIMAGE
!define MUI_PAGE_HEADER_TEXT "License Information"
!define MUI_PAGE_HEADER_SUBTEXT "Please review the license terms before installing ${APP_NAME}."
!define MUI_LICENSEPAGE_TEXT_TOP "Press Page Down or scroll to see the rest of the license."
!define MUI_LICENSEPAGE_TEXT_BOTTOM " "
!define MUI_LICENSEPAGE_BUTTON "&Next >"

!define MUI_ABORTWARNING
!define MUI_FINISHPAGE_TITLE "Setup Complete"
!define MUI_FINISHPAGE_RUN
!define MUI_FINISHPAGE_RUN_FUNCTION LaunchAymurAI
!define MUI_FINISHPAGE_SHOWREADME "https://github.com/AymurAI/desktop-app/releases"
!define MUI_FINISHPAGE_SHOWREADME_TEXT "View Release Notes"
!define MUI_FINISHPAGE_SHOWREADME_NOTCHECKED
!define MUI_FINISHPAGE_LINK "Learn more about AymurAI"
!define MUI_FINISHPAGE_LINK_LOCATION "https://www.aymurai.info/"
!define MUI_FINISHPAGE_LINK_COLOR 3F479D

Function LaunchAymurAI
    ; Check if the frontend executable exists before launching
    IfFileExists "$INSTDIR\${APP_NAME}.exe" 0 +3
        Exec "$INSTDIR\${APP_NAME}.exe"
        Return
    MessageBox MB_ICONEXCLAMATION|MB_OK "AymurAI desktop application is not installed or missing.$\r$\nPlease verify that you selected the frontend component during installation."
FunctionEnd

!define UNINST_MINICONDA_VAR "UNINSTALL_MINICONDA"

Var UNINSTALL_MINICONDA
Var MinicondaCheckbox

;--------------------------------

; Modern UI pages
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "..\resources\license.txt"
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

; Uninstall pages
UninstPage custom un.MinicondaPageCreate un.MinicondaPageLeave
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

!insertmacro MUI_LANGUAGE "English"

;--------------------------------

Function CheckPrerequisites
    ; Check Miniconda in USERPROFILE only (standard location)
    ReadEnvStr $R0 "USERPROFILE"
    StrCpy $R1 "$R0\miniconda3"

    ; Check for Miniconda (conda.exe)
    IfFileExists "$R1\Scripts\conda.exe" CheckLibreOffice
    ; If we get here, Miniconda is not installed
    MessageBox MB_ICONSTOP|MB_OK "Miniconda is required but was not found in:$\r$\n$R1.$\r$\nPlease install Miniconda before continuing."
    Abort
    
    CheckLibreOffice:
        ; Check LibreOffice installation by registry key
        ClearErrors
        ReadRegStr $R5 HKLM "SOFTWARE\LibreOffice\LibreOffice" "Path"
        IfErrors 0 LibreOK
        ; Check for LibreOffice executable as a fallback
        IfFileExists "$PROGRAMFILES\LibreOffice\program\soffice.exe" LibreOK 0
        IfFileExists "$PROGRAMFILES64\LibreOffice\program\soffice.exe" LibreOK 0
        MessageBox MB_ICONSTOP|MB_OK "LibreOffice is required but was not found in the standard installation paths.$\r$\nPlease install LibreOffice before continuing."
        Abort

    LibreOK:
        Return
FunctionEnd

Function .onInit
    Call CheckPrerequisites
FunctionEnd

;--------------------------------

Section "Backend" SecBackend
    ; Execute custom .nsh headers for backend setup
    !insertmacro InstallBackend
    AddSize 2254864 ; Add size for backend files

    ; Create uninstaller file
    WriteUninstaller "$INSTDIR\Uninstall.exe"
    AddSize 64 ; Add size for uninstaller file

    ; Add registry entries for Add/Remove Programs
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "DisplayName" "${APP_NAME}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "UninstallString" '"$INSTDIR\Uninstall.exe"'
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "DisplayIcon" "$INSTDIR\${APP_NAME}.exe,0"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "Publisher" "DataGenero - Collective AI"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "DisplayVersion" "${APP_VERSION}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "URLInfoAbout" "https://www.aymurai.info/"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "InstallLocation" "$INSTDIR"
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "NoModify" 1
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "NoRepair" 1
SectionEnd

; Define a subsection for frontend-related components
SubSection "Frontend" SubSecFrontend
    Section "Desktop app" SecDesktopApp
        ; Execute custom .nsh headers for frontend setup
        !insertmacro InstallFrontend
        AddSize 232260 ; Add size for frontend files
    SectionEnd

    Section "Shortcuts" SecShortcuts
        ; Create a shortcut on the desktop to the client executable
        CreateShortCut "$DESKTOP\${APP_NAME}.lnk" "$INSTDIR\${APP_NAME}.exe"
        
        ; Create a shortcut in the Start Menu Programs folder
        CreateShortCut "$SMPROGRAMS\${APP_NAME}.lnk" "$INSTDIR\${APP_NAME}.exe"
    SectionEnd
SubSectionEnd

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
    ; Insert descriptions for each section
    !insertmacro MUI_DESCRIPTION_TEXT ${SecBackend} "Installs the AymurAI backend services."
    !insertmacro MUI_DESCRIPTION_TEXT ${SecDesktopApp} "Installs the AymurAI desktop application."
    !insertmacro MUI_DESCRIPTION_TEXT ${SecShortcuts} "Creates desktop shortcuts for easy access."
!insertmacro MUI_FUNCTION_DESCRIPTION_END

Function .onSelChange
    ; Prevent shortcuts selection without desktop app
    ${IfNot} ${SectionIsSelected} ${SecDesktopApp}
        !insertmacro UnselectSection ${SecShortcuts}
    ${EndIf}
FunctionEnd

;--------------------------------

Section "Uninstall"
    ; Pass the Miniconda removal choice to the macro
    !insertmacro Uninstall
SectionEnd

Function un.MinicondaPageCreate
    ; Custom Uninstall Miniconda Checkbox Page
    !insertmacro MUI_HEADER_TEXT "Uninstall Options" "Select additional components to remove"
    nsDialogs::Create 1018
    Pop $0

    ${NSD_CreateCheckbox} 0u 20u 100% 12u "Remove Miniconda (not recommended)"
    Pop $MinicondaCheckbox
    ${NSD_SetState} $MinicondaCheckbox ${BST_UNCHECKED}
    ${NSD_CreateLabel} 0u 36u 100% 24u "Warning: Only check this if you are sure no other Conda environments are needed. This will remove Miniconda and all its environments."
    nsDialogs::Show
FunctionEnd

Function un.MinicondaPageLeave
    ${NSD_GetState} $MinicondaCheckbox $UNINSTALL_MINICONDA
FunctionEnd
