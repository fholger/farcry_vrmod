set DIR=%~dp0
call %DIR%\make_dist.bat

xcopy /e /i /y %DIR%\dist\ %FARCRY_INSTALL_DIR%
