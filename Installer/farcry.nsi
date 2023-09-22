!include "MUI2.nsh"
!include "WordFunc.nsh"
!define VERSION '1.0.0'

Name "Far Cry VR Mod"
; should not need admin privileges as the install folder should be user writable, anyway
RequestExecutionLevel user

OutFile ".\farcry-vrmod-${VERSION}.exe"

!define MUI_ICON '.\farcry.ico'

!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP ".\header.bmp"
!define MUI_WELCOMEFINISHPAGE_BITMAP ".\welcome.bmp"
!define MUI_WELCOMEPAGE_TITLE 'FarCry VR Mod v${VERSION}'
!define MUI_WELCOMEPAGE_TEXT 'This will install the FarCry VR Mod on your computer. \
Please be aware that this is an early development version, and bugs are to be expected. \
It features a full roomscale VR experience with motion controller support.'

!define MUI_DIRECTORYPAGE_TEXT 'Please enter the location of your FarCry installation.'

!define MUI_COMPONENTSPAGE_NODESC

!define MUI_FINISHPAGE_TITLE 'Installation complete.'
!define MUI_FINISHPAGE_TEXT 'You can launch the VR Mod by running FarCryVR.exe from your FarCry install directory.'
!define MUI_FINISHPAGE_SHOWREADME 'https://farcryvr.de/manual/'
!define MUI_FINISHPAGE_SHOWREADME_TEXT 'Show Far Cry VR manual'
!define MUI_FINISHPAGE_NOREBOOTSUPPORT

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

!insertmacro MUI_LANGUAGE "English"

Section "!Mod files"
	SectionIn RO
	SetOutPath $INSTDIR\Mods\CryVR
	File /r .\assembly\Mods\CryVR\*

	SetOutPath $INSTDIR\Bin32
	File .\assembly\Bin32\*

	SetOutPath $INSTDIR
	File .\assembly\FarCryVR.exe
	File .\assembly\FarCryVR_dev.bat
	
	WriteUninstaller "$INSTDIR\Uninstall_FarCryVR.exe"
SectionEnd

Section "Start menu shortcut"
	CreateShortcut "$SMPrograms\$(^Name).lnk" "$InstDir\FarCryVR.exe"
SectionEnd

Section /o "Desktop shortcut"
	CreateShortcut "$Desktop\$(^Name).lnk" "$InstDir\FarCryVR.exe"
SectionEnd

Section "Uninstall"
	SetOutPath $INSTDIR
	RMDir /r "$INSTDIR\Mods\CryVR"
	Delete "$INSTDIR\FarCryVR.exe"
	Delete "$INSTDIR\FarCryVR_dev.bat"
	Delete "$INSTDIR\Bin32\d3d9.dll"
	Delete "$INSTDIR\Bin32\openvr_api.dll"
	Delete "$INSTDIR\Bin32\avcodec-60.dll"
	Delete "$INSTDIR\Bin32\avdevice-60.dll"
	Delete "$INSTDIR\Bin32\avfilter-9.dll"
	Delete "$INSTDIR\Bin32\avformat-60.dll"
	Delete "$INSTDIR\Bin32\avutil-58.dll"
	Delete "$INSTDIR\Bin32\swresample-4.dll"
	Delete "$INSTDIR\Bin32\swscale-7.dll"
	Delete "$SMPrograms\$(^Name).lnk"
	Delete "$Desktop\$(^Name).lnk"
	Delete "Uninstall_FarCryVR.exe"
SectionEnd

Function .onInit
	; try to look up install directory for the GOG.com version of Far Cry
	SetRegView 32
	ReadRegStr $R0 HKLM "Software\GOG.com\Games\1207658750" "path"
	IfErrors lbl_checksteam 0
	StrCpy $INSTDIR $R0
	Return
	
	lbl_checksteam:
	; try to look up install directory for the Steam version of Far Cry
	SetRegView 64
	ReadRegStr $R0 HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Steam App 13520" "InstallLocation"
	IfErrors lbl_checkubi 0
	StrCpy $INSTDIR $R0
	Return

	lbl_checkubi:
	; try to look up install directory for the Ubisoft version of Far Cry
	SetRegView 32
	ReadRegStr $R0 HKLM "Software\Ubisoft\Launcher\Installs\84" "InstallDir"
	IfErrors lbl_fallback 0
	${WordReplace} $R0 "/" "\" "+" $R0
	StrCpy $INSTDIR $R0
	Return
	
	lbl_fallback:
	StrCpy $INSTDIR "$PROGRAMFILES32\Steam\steamapps\common\FarCry"
FunctionEnd
