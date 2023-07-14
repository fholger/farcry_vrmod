!include "MUI2.nsh"
!define VERSION '0.1.1'

Name "FarCry VR Mod"

OutFile ".\farcry-vrmod-${VERSION}.exe"

!define MUI_ICON '.\farcry.ico'

!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP ".\header.bmp"
!define MUI_WELCOMEFINISHPAGE_BITMAP ".\welcome.bmp"
!define MUI_WELCOMEPAGE_TITLE 'FarCry VR Mod v${VERSION}'
!define MUI_WELCOMEPAGE_TEXT 'This will install the FarCry VR Mod on your computer. \
Please be aware that this is an early development version, and bugs are to be expected. \
It is a seated-only experience for now without any motion controller support.'

!define MUI_DIRECTORYPAGE_TEXT 'Please enter the location of your FarCry installation.'

!define MUI_FINISHPAGE_TITLE 'Installation complete.'
!define MUI_FINISHPAGE_TEXT 'You can launch the VR Mod by running FarCryVR.bat from your FarCry install directory.'


!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_LANGUAGE "English"

Section "" 
	SetOutPath $INSTDIR\Mods\CryVR
	File /r .\assembly\Mods\CryVR\*

	SetOutPath $INSTDIR\Bin32
	File .\assembly\Bin32\*

	SetOutPath $INSTDIR
	File .\assembly\FarCryVR.bat
SectionEnd

Function .onInit
	StrCpy $INSTDIR "C:\Program Files (x86)\Steam\steamapps\common\FarCry"
FunctionEnd
