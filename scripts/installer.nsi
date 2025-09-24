; Main Installer Script
Unicode true
ManifestDPIAware true

!define APP_NAME "AymurAI"
!define APP_VERSION "1.1"
!define OUTPUT_DIR "..\build"

; Installer Information
Name "${APP_NAME} v${APP_VERSION}"
OutFile "${OUTPUT_DIR}\${APP_NAME}-Installer.exe"
BrandingText "DataGénero - Collective AI"

; Language storage and defaults
!define MUI_LANGDLL_REGISTRY_ROOT HKCU
!define MUI_LANGDLL_REGISTRY_KEY "Software\${APP_NAME}\Installer"
!define MUI_LANGDLL_REGISTRY_VALUENAME "Language"
!define MUI_LANGDLL_ALWAYSSHOW

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

; Language settings
!define MUI_LANGDLL_DEFAULT_LANG ${LANG_SPANISH}
!define MUI_LANGDLL_WINDOWTITLE "${APP_NAME} v${APP_VERSION}"
!define MUI_LANGDLL_INFO "Selecciona idioma / Select language"

!insertmacro MUI_RESERVEFILE_LANGDLL

;--------------------------------
; UI assets and text definitions

!define MUI_ICON "..\resources\api\static\logo256-text.ico"
!define MUI_HEADERIMAGE_BITMAP "..\resources\header.bmp"
!define MUI_WELCOMEFINISHPAGE_BITMAP "..\resources\banner.bmp"

!define MUI_WELCOMEPAGE_TEXT "$(STR_WELCOME_TEXT)"

!define MUI_HEADERIMAGE
!define MUI_PAGE_HEADER_TEXT "$(STR_TERMS_HEADER)"
!define MUI_PAGE_HEADER_SUBTEXT "$(STR_TERMS_SUBHEADER)"
!define MUI_LICENSEPAGE_TEXT_TOP "$(STR_LICENSE_TOP)"
!define MUI_LICENSEPAGE_TEXT_BOTTOM " "

!define MUI_ABORTWARNING
!define MUI_FINISHPAGE_TITLE "$(STR_FINISH_TITLE)"
!define MUI_FINISHPAGE_RUN
!define MUI_FINISHPAGE_RUN_FUNCTION LaunchAymurAI
!define MUI_FINISHPAGE_RUN_TEXT "$(STR_FINISH_RUN_TEXT)"
!define MUI_FINISHPAGE_SHOWREADME "https://github.com/AymurAI/desktop-app/releases"
!define MUI_FINISHPAGE_SHOWREADME_TEXT "$(STR_FINISH_RELEASE_NOTES)"
!define MUI_FINISHPAGE_SHOWREADME_NOTCHECKED
!define MUI_FINISHPAGE_LINK "$(STR_FINISH_LINK_TEXT)"
!define MUI_FINISHPAGE_LINK_LOCATION "https://www.aymurai.info/"
!define MUI_FINISHPAGE_LINK_COLOR 3F479D

Function LaunchAymurAI
    ; Check if the frontend executable exists before launching
    IfFileExists "$INSTDIR\${APP_NAME}.exe" 0 +3
        Exec "$INSTDIR\${APP_NAME}.exe"
        Return
    MessageBox MB_ICONEXCLAMATION|MB_OK "$(STR_LAUNCH_MISSING)"
FunctionEnd

!define UNINST_MINICONDA_VAR "UNINSTALL_MINICONDA"

Var UNINSTALL_MINICONDA
Var MinicondaCheckbox
Var UNINSTALL_APPDATA
Var RemoveDataCheckbox

;--------------------------------

; Modern UI pages
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "$(STR_LICENSE_FILE)"
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

; Uninstall pages
UninstPage custom un.RemoveDataPageCreate un.RemoveDataPageLeave
UninstPage custom un.MinicondaPageCreate un.MinicondaPageLeave
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

;--------------------------------
; Language strings

!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "Spanish"

LangString STR_WELCOME_TEXT ${LANG_SPANISH} "Este asistente te guiará en la instalación de ${APP_NAME} en tu equipo.$\r$\n$\r$\nSe recomienda cerrar las demás aplicaciones antes de comenzar.$\r$\n$\r$\nAsegúrate de tener LibreOffice y Miniconda instalados, ya que son necesarios para que ${APP_NAME} funcione correctamente.$\r$\n$\r$\nHaz clic en Siguiente para continuar."
LangString STR_WELCOME_TEXT ${LANG_ENGLISH} "This setup will guide you through the installation of ${APP_NAME} on your system.$\r$\n$\r$\nIt is recommended that you close all other applications before starting.$\r$\n$\r$\nMake sure you have LibreOffice and Miniconda installed on your system, as they are required for ${APP_NAME} to function properly.$\r$\n$\r$\nClick Next to continue."

LangString STR_DETAIL_BACKEND_INSTALL ${LANG_SPANISH} "Instalando dependencias del backend..."
LangString STR_DETAIL_BACKEND_INSTALL ${LANG_ENGLISH} "Installing backend dependencies..."

LangString STR_DETAIL_BACKEND_REMOVE ${LANG_SPANISH} "Eliminando archivos temporales..."
LangString STR_DETAIL_BACKEND_REMOVE ${LANG_ENGLISH} "Removing installation files..."

LangString STR_DETAIL_BACKEND_SUCCESS ${LANG_SPANISH} "Instalación del backend completada."
LangString STR_DETAIL_BACKEND_SUCCESS ${LANG_ENGLISH} "Backend installation successful."

LangString STR_DETAIL_BACKEND_FAIL ${LANG_SPANISH} "La instalación del backend falló. Revisá el archivo install.log para más detalles."
LangString STR_DETAIL_BACKEND_FAIL ${LANG_ENGLISH} "Backend installation failed. Please check install.log for details."

LangString STR_DETAIL_FRONTEND_SKIP ${LANG_SPANISH} "El frontend ya está instalado."
LangString STR_DETAIL_FRONTEND_SKIP ${LANG_ENGLISH} "Frontend is already installed."

LangString STR_DETAIL_FRONTEND_DOWNLOAD ${LANG_SPANISH} "Descargando el frontend..."
LangString STR_DETAIL_FRONTEND_DOWNLOAD ${LANG_ENGLISH} "Downloading frontend..."

LangString STR_DETAIL_FRONTEND_EXTRACT ${LANG_SPANISH} "Extrayendo el frontend..."
LangString STR_DETAIL_FRONTEND_EXTRACT ${LANG_ENGLISH} "Extracting frontend..."

LangString STR_DETAIL_FRONTEND_SUCCESS ${LANG_SPANISH} "Instalación del frontend completada."
LangString STR_DETAIL_FRONTEND_SUCCESS ${LANG_ENGLISH} "Frontend installation successful."

LangString STR_DETAIL_FRONTEND_FAIL ${LANG_SPANISH} "La instalación del frontend falló. Intentá nuevamente."
LangString STR_DETAIL_FRONTEND_FAIL ${LANG_ENGLISH} "Frontend installation failed. Please try again."

LangString STR_TERMS_HEADER ${LANG_SPANISH} "Términos y condiciones"
LangString STR_TERMS_HEADER ${LANG_ENGLISH} "Terms and Conditions"

LangString STR_TERMS_SUBHEADER ${LANG_SPANISH} "Revisa los términos y condiciones antes de instalar ${APP_NAME}."
LangString STR_TERMS_SUBHEADER ${LANG_ENGLISH} "Please review the terms and conditions before installing ${APP_NAME}."

LangString STR_LICENSE_TOP ${LANG_SPANISH} "Presiona Av Pág o desplázate para ver el resto de los términos y condiciones."
LangString STR_LICENSE_TOP ${LANG_ENGLISH} "Press Page Down or scroll to see the rest of the terms and conditions."

LangString STR_FINISH_TITLE ${LANG_SPANISH} "Instalación completada"
LangString STR_FINISH_TITLE ${LANG_ENGLISH} "Setup Complete"

LangString STR_FINISH_RUN_TEXT ${LANG_SPANISH} "Iniciar ${APP_NAME}"
LangString STR_FINISH_RUN_TEXT ${LANG_ENGLISH} "Launch ${APP_NAME}"

LangString STR_FINISH_RELEASE_NOTES ${LANG_SPANISH} "Ver notas de la versión"
LangString STR_FINISH_RELEASE_NOTES ${LANG_ENGLISH} "View Release Notes"

LangString STR_FINISH_LINK_TEXT ${LANG_SPANISH} "Más información sobre AymurAI"
LangString STR_FINISH_LINK_TEXT ${LANG_ENGLISH} "Learn more about AymurAI"

LangString STR_LAUNCH_MISSING ${LANG_SPANISH} "La aplicación de escritorio de AymurAI no está instalada o falta.$\r$\nVerifica que hayas seleccionado el componente de interfaz durante la instalación."
LangString STR_LAUNCH_MISSING ${LANG_ENGLISH} "AymurAI desktop application is not installed or missing.$\r$\nPlease verify that you selected the frontend component during installation."

LangString STR_MINICONDA_MISSING ${LANG_SPANISH} "Se requiere Miniconda pero no se encontró en:$\r$\n$R1.$\r$\nInstala Miniconda antes de continuar."
LangString STR_MINICONDA_MISSING ${LANG_ENGLISH} "Miniconda is required but was not found in:$\r$\n$R1.$\r$\nPlease install Miniconda before continuing."

LangString STR_LIBREOFFICE_MISSING ${LANG_SPANISH} "Se requiere LibreOffice pero no se encontró en las rutas de instalación habituales.$\r$\nInstala LibreOffice antes de continuar."
LangString STR_LIBREOFFICE_MISSING ${LANG_ENGLISH} "LibreOffice is required but was not found in the standard installation paths.$\r$\nPlease install LibreOffice before continuing."

LangString STR_SECTION_BACKEND ${LANG_SPANISH} "Servicios backend"
LangString STR_SECTION_BACKEND ${LANG_ENGLISH} "Backend"

LangString STR_SECTION_FRONTEND ${LANG_SPANISH} "Interfaz gráfica"
LangString STR_SECTION_FRONTEND ${LANG_ENGLISH} "Frontend"

LangString STR_SECTION_DESKTOP ${LANG_SPANISH} "Aplicación de escritorio"
LangString STR_SECTION_DESKTOP ${LANG_ENGLISH} "Desktop app"

LangString STR_SECTION_SHORTCUTS ${LANG_SPANISH} "Accesos directos"
LangString STR_SECTION_SHORTCUTS ${LANG_ENGLISH} "Shortcuts"

LangString STR_DESC_BACKEND ${LANG_SPANISH} "Instala los servicios backend de AymurAI."
LangString STR_DESC_BACKEND ${LANG_ENGLISH} "Installs the AymurAI backend services."

LangString STR_DESC_DESKTOP ${LANG_SPANISH} "Instala la aplicación de escritorio de AymurAI."
LangString STR_DESC_DESKTOP ${LANG_ENGLISH} "Installs the AymurAI desktop application."

LangString STR_DESC_SHORTCUTS ${LANG_SPANISH} "Crea accesos directos para un acceso rápido."
LangString STR_DESC_SHORTCUTS ${LANG_ENGLISH} "Creates desktop shortcuts for easy access."

LangString STR_UNINSTALL_HEADER ${LANG_SPANISH} "Opciones de desinstalación"
LangString STR_UNINSTALL_HEADER ${LANG_ENGLISH} "Uninstall Options"

LangString STR_UNINSTALL_SUBHEADER ${LANG_SPANISH} "Selecciona componentes adicionales para eliminar"
LangString STR_UNINSTALL_SUBHEADER ${LANG_ENGLISH} "Select additional components to remove"

LangString STR_UNINSTALL_MINICONDA_HEADER ${LANG_SPANISH} "Eliminar Miniconda"
LangString STR_UNINSTALL_MINICONDA_HEADER ${LANG_ENGLISH} "Remove Miniconda"

LangString STR_UNINSTALL_MINICONDA_SUBHEADER ${LANG_SPANISH} "Decide si querés desinstalar Miniconda"
LangString STR_UNINSTALL_MINICONDA_SUBHEADER ${LANG_ENGLISH} "Choose whether to uninstall Miniconda"

LangString STR_UNINSTALL_DATA_HEADER ${LANG_SPANISH} "Eliminar datos locales"
LangString STR_UNINSTALL_DATA_HEADER ${LANG_ENGLISH} "Remove local data"

LangString STR_UNINSTALL_DATA_SUBHEADER ${LANG_SPANISH} "Selecciona si querés borrar caché, modelos y base de datos"
LangString STR_UNINSTALL_DATA_SUBHEADER ${LANG_ENGLISH} "Choose whether to remove cache, models, and database"

LangString STR_UNINSTALL_REMOVE_MINICONDA ${LANG_SPANISH} "Eliminar Miniconda (no recomendado)"
LangString STR_UNINSTALL_REMOVE_MINICONDA ${LANG_ENGLISH} "Remove Miniconda (not recommended)"

LangString STR_UNINSTALL_REMOVE_MINICONDA_DESC ${LANG_SPANISH} "Advertencia: Márcalo solo si estás seguro de que no necesitas otros entornos de Conda. Esto eliminará Miniconda y todos sus entornos."
LangString STR_UNINSTALL_REMOVE_MINICONDA_DESC ${LANG_ENGLISH} "Warning: Only check this if you are sure no other Conda environments are needed. This will remove Miniconda and all its environments."

LangString STR_UNINSTALL_REMOVE_DATA ${LANG_SPANISH} "Eliminar datos de AymurAI (caché, modelos, base de datos)"
LangString STR_UNINSTALL_REMOVE_DATA ${LANG_ENGLISH} "Remove AymurAI data (cache, models, database)"

LangString STR_UNINSTALL_REMOVE_DATA_DESC ${LANG_SPANISH} "Elimina los archivos en $LOCALAPPDATA\AymurAI para este usuario."
LangString STR_UNINSTALL_REMOVE_DATA_DESC ${LANG_ENGLISH} "Deletes files under $LOCALAPPDATA\AymurAI for this user."

LicenseLangString STR_LICENSE_FILE ${LANG_ENGLISH} "..\resources\terms_and_conditions.txt"
LicenseLangString STR_LICENSE_FILE ${LANG_SPANISH} "..\resources\terms_and_conditions_es.txt"

;--------------------------------

; Functions

Function CheckPrerequisites
    ; Check Miniconda in USERPROFILE only (standard location)
    ReadEnvStr $R0 "USERPROFILE"
    StrCpy $R1 "$R0\miniconda3"

    ; Check for Miniconda (conda.exe)
    IfFileExists "$R1\Scripts\conda.exe" CheckLibreOffice
    ; If we get here, Miniconda is not installed
    MessageBox MB_ICONSTOP|MB_OK "$(STR_MINICONDA_MISSING)"
    Abort
    
    CheckLibreOffice:
        ; Check LibreOffice installation by registry key
        ClearErrors
        ReadRegStr $R5 HKLM "SOFTWARE\LibreOffice\LibreOffice" "Path"
        IfErrors 0 LibreOK
        ; Check for LibreOffice executable as a fallback
        IfFileExists "$PROGRAMFILES\LibreOffice\program\soffice.exe" LibreOK 0
        IfFileExists "$PROGRAMFILES64\LibreOffice\program\soffice.exe" LibreOK 0
        MessageBox MB_ICONSTOP|MB_OK "$(STR_LIBREOFFICE_MISSING)"
        Abort

    LibreOK:
        Return
FunctionEnd

Function .onInit
    !insertmacro MUI_LANGDLL_DISPLAY
    Call CheckPrerequisites
FunctionEnd

;--------------------------------

Section "$(STR_SECTION_BACKEND)" SecBackend
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
SubSection "$(STR_SECTION_FRONTEND)" SubSecFrontend
    Section "$(STR_SECTION_DESKTOP)" SecDesktopApp
        ; Execute custom .nsh headers for frontend setup
        !insertmacro InstallFrontend
        AddSize 232260 ; Add size for frontend files
    SectionEnd

    Section "$(STR_SECTION_SHORTCUTS)" SecShortcuts
        ; Create a shortcut on the desktop to the client executable
        CreateShortCut "$DESKTOP\${APP_NAME}.lnk" "$INSTDIR\${APP_NAME}.exe"
        
        ; Create a shortcut in the Start Menu Programs folder
        CreateShortCut "$SMPROGRAMS\${APP_NAME}.lnk" "$INSTDIR\${APP_NAME}.exe"
    SectionEnd
SubSectionEnd

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
    ; Insert descriptions for each section
    !insertmacro MUI_DESCRIPTION_TEXT ${SecBackend} "$(STR_DESC_BACKEND)"
    !insertmacro MUI_DESCRIPTION_TEXT ${SecDesktopApp} "$(STR_DESC_DESKTOP)"
    !insertmacro MUI_DESCRIPTION_TEXT ${SecShortcuts} "$(STR_DESC_SHORTCUTS)"
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
    ; Custom page for Miniconda removal
    !insertmacro MUI_HEADER_TEXT "$(STR_UNINSTALL_MINICONDA_HEADER)" "$(STR_UNINSTALL_MINICONDA_SUBHEADER)"
    nsDialogs::Create 1018
    Pop $0

    ${NSD_CreateCheckbox} 0u 28u 100% 12u "$(STR_UNINSTALL_REMOVE_MINICONDA)"
    Pop $MinicondaCheckbox
    ${NSD_SetState} $MinicondaCheckbox ${BST_UNCHECKED}
    ${NSD_CreateLabel} 0u 44u 100% 24u "$(STR_UNINSTALL_REMOVE_MINICONDA_DESC)"
    nsDialogs::Show
FunctionEnd

Function un.MinicondaPageLeave
    ${NSD_GetState} $MinicondaCheckbox $UNINSTALL_MINICONDA
FunctionEnd

Function un.RemoveDataPageCreate
    ; Custom page for data/cache removal
    !insertmacro MUI_HEADER_TEXT "$(STR_UNINSTALL_DATA_HEADER)" "$(STR_UNINSTALL_DATA_SUBHEADER)"
    nsDialogs::Create 1018
    Pop $0

    ${NSD_CreateCheckbox} 0u 28u 100% 12u "$(STR_UNINSTALL_REMOVE_DATA)"
    Pop $RemoveDataCheckbox
    ${NSD_SetState} $RemoveDataCheckbox ${BST_CHECKED}
    ${NSD_CreateLabel} 0u 44u 100% 24u "$(STR_UNINSTALL_REMOVE_DATA_DESC)"
    nsDialogs::Show
FunctionEnd

Function un.RemoveDataPageLeave
    ${NSD_GetState} $RemoveDataCheckbox $UNINSTALL_APPDATA
FunctionEnd
