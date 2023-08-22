cd bin32
copy /Y d3d9.vr.dll d3d9.dll

set DXVK_ASYNC=0
set DXVK_GPLASYNCCACHE=0
set DXVK_STARTOPENVR=1
start /B /WAIT FarCry.exe "-MOD:CryVR"

erase d3d9.dll
