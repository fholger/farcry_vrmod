set DIR=%~dp0
set DIST=%DIR%dist
if exist %DIST% (rmdir /S /Q %DIST%)
mkdir %DIST%
mkdir %DIST%\Bin32
mkdir %DIST%\Mods
mkdir %DIST%\Mods\CryVR
mkdir %DIST%\Mods\CryVR\Bin32
mkdir %DIST%\Mods\CryVR\steamvr
mkdir %DIST%\Mods\CryVR\FCData
mkdir %DIST%\Mods\CryVR\FCData\Localized

cd %DIR%\FCData
7z a CryVR.zip .\*

cd %DIR%\Localized\english
7z a english.zip .\*

copy %DIR%\ModDesc.txt %DIST%\Mods\CryVR
copy %DIR%\FarCryVR.bat %DIST%
copy %DIR%\FarCryVR_dev.bat %DIST%
copy %DIR%\README.md %DIST%\Mods\CryVR
copy %DIR%\LICENSE.md %DIST%\Mods\CryVR
copy %DIR%\EULA.txt %DIST%\Mods\CryVR
copy %DIR%\Sources\ThirdParty\openvr\bin\win32\openvr_api.dll %DIST%\Bin32\
copy %DIR%\Sources\ThirdParty\dxvk\bin\d3d9.dll %DIST%\Bin32\
copy %DIR%\Sources\ThirdParty\ffmpeg\bin\*.dll %DIST%\Bin32\
copy "%DIR%\Sources\CryGame C++\Solution1\CryGame\Release\CryGame.dll" %DIST%\Mods\CryVR\Bin32\
copy %DIR%\FCData\CryVR.zip %DIST%\Mods\CryVR\CryVR.pak
copy %DIR%\Localized\english\english.zip %DIST%\Mods\CryVR\FCData\Localized\english2.pak
copy %DIR%\steamvr\* %DIST%\Mods\CryVR\steamvr
erase %DIR%\FCData\CryVR.zip
erase %DIR%\Localized\english\english.zip