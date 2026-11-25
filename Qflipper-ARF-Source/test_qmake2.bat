@echo off
call "C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars64.bat"
cd /d "%~dp0"
C:\Qt\6.10.2\msvc2022_64\bin\qmake.exe qFlipper.pro -spec win32-msvc "QMAKE_MSC_VER=1940" "CONFIG+=release" -nocache 2>&1
