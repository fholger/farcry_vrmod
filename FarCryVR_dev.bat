cd bin32
copy /Y d3d9.vr.dll d3d9.dll

set DXVK_ASYNC=1
set DXVK_GPLASYNCCACHE=1
start /B /WAIT FarCry.exe "-MOD:CryVR" -DEVMODE

erase d3d9.dll
