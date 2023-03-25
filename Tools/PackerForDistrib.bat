
@ECHO OFF
@ECHO Syntax: PackerForDistrib (Directory Mod Name)
@ECHO Creates a pak file for distribution.

@ECHO Delete previous Distrib and DistribTemp folder
rd Distrib /S /Q
rd DistribTemp /S /Q

@ECHO Make a copy of all files in the Distrib folder.
md Distrib
md DistribTemp
xcopy %1\*.* Distrib /S /Y

@ECHO Go unzip pak files in the root, preserving the subdirs
FOR %%F IN (Distrib/*.pak) DO PKZIP25.EXE -extract=all -nozipextension -dir=root %%F %%~dpF

@ECHO Now remove previous pak files (if any)
FOR %%F IN (Distrib/*.pak) DO del %%F

@ECHO move out the files that should not be in the pak 
cd Distrib
move /Y moddesc.txt ..\DistribTemp
move /Y modPreview.dds ..\DistribTemp
move /Y levels ..\DistribTemp

@ECHO Creation of the distrib pak file
..\PKZIP25.EXE -add -nozipextension -path=current -store -recurse %1.pak *.* 

@ECHO Move the pak in the temp folder
move /Y %1.pak ..\DistribTemp
cd..
rd Distrib /S /Q
ren DistribTemp Distrib

@ECHO Done - to play it, it must be put on the user's machine
@ECHO in the subfolder Distrib or Mods/%1 

PAUSE



