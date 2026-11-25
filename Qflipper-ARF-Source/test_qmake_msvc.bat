@echo off
call "C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars64.bat"
C:\Qt\6.10.2\msvc2022_64\bin\qmake.exe -query
C:\Qt\6.10.2\msvc2022_64\bin\qmake.exe -spec win32-msvc -v 2>&1
