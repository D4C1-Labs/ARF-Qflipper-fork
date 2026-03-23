@echo off
setlocal EnableExtensions
cd /d "%~dp0"

rem --- Qt / MinGW (edit QTDIR if your install differs) ---
set "QTDIR=C:\Qt\6.10.2\mingw_64"
set "MINGW_BIN=C:\Qt\Tools\mingw1310_64\bin"
set "PATH=%MINGW_BIN%;%QTDIR%\bin;%PATH%"

set "ISCC=%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe"
if not exist "%ISCC%" set "ISCC=%ProgramFiles%\Inno Setup 6\ISCC.exe"
if not exist "%ISCC%" (
  echo ERROR: Inno Setup 6 not found. Install from https://jrsoftware.org/isdl.php
  exit /b 1
)

if not exist "%QTDIR%\bin\qmake.exe" (
  echo ERROR: Qt not found at %QTDIR%
  echo Edit QTDIR and MINGW_BIN at the top of this script.
  exit /b 1
)

echo === Clean dist (installers + staging + zip) ===
if exist dist rmdir /s /q dist
mkdir dist 2>nul

echo === Rebuild application icon from PNG (fixes purple Windows icon) ===
python "%~dp0tools\rebuild_ico_from_png.py"
if errorlevel 1 exit /b 1

echo === Force Windows .ico resource relink ===
del /f /q "%~dp0build-mingw\application\qFlipper_resource_res.o" 2>nul

echo === Building Release ===
if not exist build-mingw mkdir build-mingw
pushd build-mingw
"%QTDIR%\bin\qmake.exe" ..\qFlipper.pro -spec win32-g++ "CONFIG+=release"
if errorlevel 1 popd & exit /b 1
"%MINGW_BIN%\mingw32-make.exe" -j%NUMBER_OF_PROCESSORS%
if errorlevel 1 popd & exit /b 1
popd

echo === windeployqt ===
pushd build-mingw
"%QTDIR%\bin\windeployqt.exe" --qmldir "..\application\imports" --release "qFlipper.exe"
if errorlevel 1 popd & exit /b 1
"%QTDIR%\bin\windeployqt.exe" --release "qFlipper-cli.exe"
if errorlevel 1 popd & exit /b 1
echo === Full QML tree + Qt6 DLLs (ARF deploy) ===
xcopy /E /Y /I "%QTDIR%\qml\*" "%CD%\qml\" >nul
copy /Y "%QTDIR%\bin\Qt6*.dll" "%CD%\" >nul
popd

echo === Staging dist\ARF-qFlipper (no build trees) ===
if exist dist\ARF-qFlipper rmdir /s /q dist\ARF-qFlipper
mkdir dist\ARF-qFlipper 2>nul
robocopy build-mingw dist\ARF-qFlipper /E /XD application backend cli dfu 3rdparty "plugins\flipperproto0" "plugins\protobufinterface" /XF Makefile .qmake.stash libflipperproto0.a /NFL /NDL /NJH /NJS /nc /ns /np
set RC=%ERRORLEVEL%
if %RC% GEQ 8 (
  echo ERROR: robocopy failed with code %RC%
  exit /b 1
)

rem Standalone .ico next to exe — Windows shortcuts use IconIndex into the PE; index 0 can show the wrong
rem icon (violet) while the file icon is correct. Shortcuts reference this file instead of qFlipper.exe.
copy /Y "%~dp0application\assets\icons\qFlipper.ico" "%~dp0dist\ARF-qFlipper\qFlipper.ico" >nul
if errorlevel 1 (
  echo ERROR: could not copy qFlipper.ico into dist\ARF-qFlipper
  exit /b 1
)

echo === ZIP for web hosting (installer downloads this) ===
if exist dist\arf-qflipper-win64.zip del /f /q dist\arf-qflipper-win64.zip
tar -a -cf "dist\arf-qflipper-win64.zip" -C "dist\ARF-qFlipper" .
if errorlevel 1 (
  echo ERROR: tar zip failed
  exit /b 1
)

if exist "%~dp0..\amau-zero-hub\public\downloads" (
  echo === Copying build artifacts to amau-zero-hub\public\downloads ===
  copy /Y "dist\arf-qflipper-win64.zip" "%~dp0..\amau-zero-hub\public\downloads\"
)

echo === Inno branding BMPs ===
python "%~dp0installer\generate_inno_branding.py"
if errorlevel 1 exit /b 1

echo === Compiling installers (Web = small download bootstrap; Full = offline bundle) ===
"%ISCC%" "%~dp0installer\ARF-qFlipper-Web.iss"
if errorlevel 1 exit /b 1
"%ISCC%" "%~dp0installer\ARF-qFlipper-Full.iss"
if errorlevel 1 exit /b 1

if exist "%~dp0..\amau-zero-hub\public\downloads" (
  echo === Copying installers to amau-zero-hub\public\downloads ===
  copy /Y "dist\ARF-qFlipper-Setup.exe" "%~dp0..\amau-zero-hub\public\downloads\" 2>nul
  copy /Y "dist\ARF-qFlipper-Full-Setup.exe" "%~dp0..\amau-zero-hub\public\downloads\" 2>nul
)

echo.
echo OK:
echo   dist\ARF-qFlipper-Setup.exe   ^(web — set DownloadURL in installer\ARF-qFlipper-Web.iss^)
echo   dist\ARF-qFlipper-Full-Setup.exe
echo   dist\arf-qflipper-win64.zip   ^(upload to your site: /downloads/arf-qflipper-win64.zip^)
exit /b 0
