@echo off
setlocal
call "C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars64.bat"
cd /d "%~dp0"
if exist build-msvc rd /s /q build-msvc
mkdir build-msvc
cd build-msvc
C:\Qt\6.10.2\msvc2022_64\bin\qmake.exe ..\qFlipper.pro -spec win32-msvc "CONFIG+=release"
if errorlevel 1 exit /b 1
C:\Qt\Tools\QtCreator\bin\jom\jom.exe
if errorlevel 1 exit /b 1
echo BUILD OK
exit /b 0
