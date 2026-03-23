@echo off
setlocal
rem Quick release build (exe + Qt in build-mingw). For Inno Setup installer use: build_installer.bat
rem Adjust QTDIR if your Qt version/path differs.
set "QTDIR=C:\Qt\6.10.2\mingw_64"
set "MINGW_BIN=C:\Qt\Tools\mingw1310_64\bin"
rem Force Qt's MinGW first — otherwise an old c:\mingw (GCC 6) breaks Qt 6 / C++17.
set "PATH=%MINGW_BIN%;%QTDIR%\bin;%PATH%"

cd /d "%~dp0"
if not exist build-mingw mkdir build-mingw
cd build-mingw

"%QTDIR%\bin\qmake.exe" ..\qFlipper.pro -spec win32-g++ "CONFIG+=release"
if errorlevel 1 exit /b 1

"%MINGW_BIN%\mingw32-make.exe" -j8
if errorlevel 1 exit /b 1

"%QTDIR%\bin\windeployqt.exe" --qmldir "%~dp0application\imports" --release OmniCore-Flipper.exe
if errorlevel 1 exit /b 1

rem windeployqt often omits QML plugins/DLL deps; merge full QML tree + Qt6 DLLs so the app actually starts.
xcopy /E /Y /I "%QTDIR%\qml\*" "%CD%\qml\" >nul
copy /Y "%QTDIR%\bin\Qt6*.dll" "%CD%\" >nul

echo.
echo OK: OmniCore-Flipper.exe (and Qt runtime) in: %CD%
exit /b 0
