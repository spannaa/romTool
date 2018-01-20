@echo off
COLOR 1E
REM Header
echo.
echo #####################################################################
echo #                                                                   #
echo # romTOOL - A tool to extract and decompile all apks from a ROM zip #
echo #                                                                   #
echo # Compiled by Spannaa @ XDA                                         #
echo #                                                                   #
echo #####################################################################
REM Check the nomber of ROMs in the rom folder and stop if not one
set ROM=None
set /A filecount=0
for %%F in (rom/*.zip) do (
set /A filecount+=1
REM set zip=%%~nF%%~xF
set zip=%%~nF
)
if %filecount%==0 (
echo.
echo There is no ROM zip in the rom folder!
echo.
echo Press any key to exit
echo.
pause > nul
exit
)
if %filecount% GTR 1 (
echo.
echo There is more than one ROM zip in the rom folder!
echo.
echo Press any key to exit
echo.
pause > nul
exit
)
REM If there's only one ROM in the rom folder, set it
if %filecount%==1 set ROM=%zip%
REM Unzip ROM
echo.
echo Unzipping %ROM%...
if exist extracted rmdir /S /Q extracted > nul
mkdir extracted
cd tools
7za x -o..\extracted ..\rom\%ROM%.zip > nul
REM Unpack system.new.dat.br
if exist ..\extracted\system.new.dat.br (
echo.
echo Unpacking system.new.dat.br...
brotli --decompress --in ..\extracted\system.new.dat.br --out ..\extracted\system.new.dat 
)
REM Unpack system.new.dat
if exist ..\extracted\system.new.dat (
echo.
echo Unpacking system.new.dat...
echo.
sdat2img ..\extracted\system.transfer.list ..\extracted\system.new.dat ..\extracted\system.img
)
REM Unpack system.img
if exist ..\extracted\system.img (
echo.
echo Unpacking system.img...
Imgextractor ..\extracted\system.img ..\extracted\system -i
)
REM Copy all apks from extracted folder to apks folder
echo.
echo Extracting apks...
if exist ..\apks rmdir /S /Q ..\apks > nul
mkdir ..\apks
for /R ..\extracted %%f in (*.apk) do copy %%f ..\apks > nul
REM Copy all frameworks from extracted\system\framework folder to frameworks folder
if exist ..\frameworks rmdir /S /Q ..\frameworks > nul
mkdir ..\frameworks
for /R ..\extracted\system\framework %%f in (*.apk) do copy %%f ..\frameworks > nul
REM Copy original rom & build.prop to output folder and delete the originals
if exist ..\%ROM% rmdir /S /Q ..\%ROM% > nul
mkdir ..\%ROM%
copy ..\extracted\system\build.prop ..\%ROM%\build.prop > nul
del /Q ..\extracted\system\build.prop > nul
copy ..\rom\%ROM%.zip ..\%ROM%\%ROM%.zip > nul
del /Q ..\rom\%ROM%.zip > nul
REM Delete extracted folder
rmdir /q /s ..\extracted > nul
REM End of extraction phase - Pause before decompiling
echo.
echo All apks have been extracted from %ROM%
echo.
echo Press any key to start apktool
echo.
pause > nul
REM Clear screen before decompiling
cls
REM Delete old frameworks
if exist %userprofile%\AppData\Local\apktool rmdir /S /Q %userprofile%\AppData\Local\apktool > nul
if exist %userprofile%\apktool rmdir /S /Q %userprofile%\apktool > nul
if exist %userprofile%\AppData\Local\Temp\*.apk del /Q %userprofile%\AppData\Local\Temp\*.apk > nul
REM Install frameworks
echo.
echo Installing frameworks...
echo.
for %%F in (../frameworks/*.apk) do (
echo   Installing: %%F...
java -jar apktool.jar if ..\frameworks\%%F > nul 2> nul
)
REM Delete frameworks folder after installing frameworks
rmdir /S /Q ..\frameworks > nul
REM Decompile all apks
echo.
echo Decompiling apks...
echo.
for %%F in (../apks/*.apk) do (
echo   Decompiling %%F...
java -Xmx512m -jar apktool.jar decode ..\apks\%%F -o ..\%ROM%\%%F  > nul 2> nul
if errorlevel 1 (echo   There was an error decompiling %%F
echo   - Press any key to ignore this apk and continue
pause > nul
)
REM Delete original apk after decompiling to save disk space
del /Q ..\apks\%%F > nul
)
REM Delete apks folder
rmdir /S /Q ..\apks > nul
REM Location of decompiled apks
echo.
echo Decompiling complete
echo.
echo The original rom, it's build.prop ^& decompiled apks can be found 
echo in the %ROM% folder
echo.
echo.
echo #####################################################################
echo #                                                                   #
echo # romTOOL - A tool to extract and decompile all apks from a ROM zip #
echo #                                                                   #
echo # Compiled by Spannaa @ XDA                                         #
echo #                                                                   #
echo # Credits:                                                          #
echo #                                                                   #
echo # 7za standalone command line version of 7-Zip: Igor Pavlov         #
echo # Extractor: Alexey71 @ XDA ^& xpirt @ XDA                           #
echo # apktool: iBotPeaches @ XDA ^& Brut.all @ XDA                       #
echo #                                                                   #
echo #####################################################################
echo.
echo.
REM Pause before exiting
echo Press any key to exit
echo.
pause > nul
REM Exit
exit