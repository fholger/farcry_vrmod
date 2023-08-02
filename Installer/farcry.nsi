!include "MUI2.nsh"
!include LogicLib.nsh
!define VERSION '0.4.0a'

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

# copy-pasted from here: https://nsis.sourceforge.io/StrRep
!define StrRep "!insertmacro StrRep"
!macro StrRep output string old new
	Push `${string}`
	Push `${old}`
	Push `${new}`
	!ifdef __UNINSTALL__
		Call un.StrRep
	!else
		Call StrRep
	!endif
	Pop ${output}
!macroend

!macro Func_StrRep un
	Function ${un}StrRep
		Exch $R2 ;new
		Exch 1
		Exch $R1 ;old
		Exch 2
		Exch $R0 ;string
		Push $R3
		Push $R4
		Push $R5
		Push $R6
		Push $R7
		Push $R8
		Push $R9

		StrCpy $R3 0
		StrLen $R4 $R1
		StrLen $R6 $R0
		StrLen $R9 $R2
		loop:
			StrCpy $R5 $R0 $R4 $R3
			StrCmp $R5 $R1 found
			StrCmp $R3 $R6 done
			IntOp $R3 $R3 + 1 ;move offset by 1 to check the next character
			Goto loop
		found:
			StrCpy $R5 $R0 $R3
			IntOp $R8 $R3 + $R4
			StrCpy $R7 $R0 "" $R8
			StrCpy $R0 $R5$R2$R7
			StrLen $R6 $R0
			IntOp $R3 $R3 + $R9 ;move offset by length of the replacement string
			Goto loop
		done:

		Pop $R9
		Pop $R8
		Pop $R7
		Pop $R6
		Pop $R5
		Pop $R4
		Pop $R3
		Push $R0
		Push $R1
		Pop $R0
		Pop $R1
		Pop $R0
		Pop $R2
		Exch $R1
	FunctionEnd
!macroend
!insertmacro Func_StrRep ""
!insertmacro Func_StrRep "un."
# end copy-paste

Section "" 
	SetOutPath $INSTDIR\Mods\CryVR
	File /r .\assembly\Mods\CryVR\*

	SetOutPath $INSTDIR\Bin32
	File .\assembly\Bin32\*

	SetOutPath $INSTDIR
	File .\assembly\FarCryVR*.bat
SectionEnd

Function .onInit
	ReadRegStr $0 HKCU "SOFTWARE\Valve\Steam" "SteamPath"
	${StrRep} $1 $0 "/" "\"  # steam saves the path with forward slashes, so we convert them to windows style
	${If} $1 == ""
		StrCpy $INSTDIR "C:\Program Files (x86)\Steam\steamapps\common\FarCry"
	${Else}
		StrCpy $INSTDIR "$1\steamapps\common\FarCry"
	${EndIf}
FunctionEnd
