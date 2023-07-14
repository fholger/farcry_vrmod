set DIR=%~dp0
call make_dist.bat

xcopy /e /i /y %DIR%\dist\ %FARCRY_INSTALL_DIR%
