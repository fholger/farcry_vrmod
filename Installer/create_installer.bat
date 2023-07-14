set CURRENT_DIR=%~dp0
set PACKAGE_DIR=%CURRENT_DIR%\assembly
if exist %PACKAGE_DIR% (rmdir /S /Q %PACKAGE_DIR%)

set FARCRY_INSTALL_DIR=%PACKAGE_DIR%
call %CURRENT_DIR%\..\install.bat
call "C:\Program Files (x86)\NSIS\makensis.exe" farcry.nsi
