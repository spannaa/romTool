@echo off
COLOR 1E
REM Header
echo.
echo #####################################################################
echo #                              romTOOL                              #
echo #                                                                   #
echo #    Extract system image and decompile all apks from a ROM zip     #
echo #                                                                   #
echo #                     Compiled by Spannaa @ XDA                     #
echo #####################################################################
REM Check the nomber of ROMs in the rom folder and stop if not one
set ROM=None
set /A filecount=0
for %%F in (rom/*.zip) do (
set /A filecount+=1
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
brotli.exe -d ..\extracted\system.new.dat.br -o ..\extracted\system.new.dat
)
REM Unpack system.new.dat
if exist ..\extracted\system.new.dat (
echo.
echo Unpacking system.new.dat...
echo.
sdat2img ..\extracted\system.transfer.list ..\extracted\system.new.dat ..\extracted\system.img
)
REM Unpack payload.bin
if exist ..\extracted\payload.bin (
echo.
echo Unpacking payload.bin...
echo.
if exist payload_input rmdir /S /Q payload_input > nul
mkdir payload_input
if exist payload_output rmdir /S /Q payload_output > nul
mkdir payload_output
copy ..\extracted\payload.bin payload_input\payload.bin > nul
payload_dumper 
copy payload_output\system.img ..\extracted\system.img > nul
rmdir /S /Q payload_input > nul
rmdir /S /Q payload_output > nul
)
REM Unpack system.img
if exist ..\extracted\system.img (
echo.
echo Unpacking system.img...
Imgextractor ..\extracted\system.img ..\extracted\system -i
)
REM Copy original rom to output folder and delete the original
if exist ..\%ROM% rmdir /S /Q ..\%ROM% > nul
mkdir ..\%ROM%
copy ..\rom\%ROM%.zip ..\%ROM%\%ROM%.zip > nul
del /Q ..\rom\%ROM%.zip > nul
REM Move system folder to output folder
rem 	- if system is from a payload.bin rom
if exist ..\extracted\system\system (
move ..\extracted\system\system ..\%ROM%\system > nul
rmdir /S /Q ..\extracted\system > nul 2> nul
)
rem 	- if system is from any other rom
if exist ..\extracted\system (
move ..\extracted\system ..\%ROM%\system > nul
)
REM Delete extracted folder
rmdir /S /Q ..\extracted > nul 2> nul
if exist ..\extracted rmdir /S /Q extracted > nul 2> nul
REM Copy all apks from the ROM\system folder to apks folder
echo.
echo Extracting apks...
if exist ..\%ROM%\apks rmdir /S /Q ..\%ROM%\apks > nul
mkdir ..\%ROM%\apks
for /R ..\%ROM%\system %%F in (*.apk) do copy %%F ..\%ROM%\apks > nul
REM Copy all frameworks from the ROM\system\framework folder to frameworks folder
if exist ..\%ROM%\frameworks rmdir /S /Q ..\%ROM%\frameworks > nul
mkdir ..\%ROM%\frameworks
for /R ..\%ROM%\system\framework %%F in (*.apk) do copy %%F ..\%ROM%\frameworks > nul
REM End of extraction phase - Pause before decompiling
echo.
echo The system image has been extracted from %ROM%
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
for %%F in (../%ROM%/frameworks/*.apk) do (
echo   Installing: %%F...
java -jar apktool.jar if ..\%ROM%\frameworks\%%F > nul 2> nul
)
REM Delete frameworks folder
rmdir /S /Q ..\%ROM%\frameworks > nul
REM Decompile all apks
echo.
echo Decompiling apks...
echo.
mkdir ..\%ROM%\decompiled-apks
for %%F in (../%ROM%/apks/*.apk) do (
echo   Decompiling %%F...
java -Xmx512m -jar apktool.jar decode ..\%ROM%\apks\%%F -o ..\%ROM%\decompiled-apks\%%F  > nul 2> nul
if errorlevel 1 (
echo    - error decompiling %%F
)
REM Delete original apk after decompiling to save disk space
del /Q ..\%ROM%\apks\%%F > nul
)
REM Delete apks folder
rmdir /S /Q ..\%ROM%\apks > nul
REM Location of output files and credits
echo Decompiling complete
echo.
echo The original rom, extracted system image ^& decompiled apks can be found 
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
echo # Brotli.exe: Eric Lawrence                                         #
echo # Extractor: Alexey71 @ XDA ^& xpirt @ XDA                           #
echo # payload_dumper-win64: geminids14 @ XDA                            #
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
