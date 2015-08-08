@echo off
set rarpath="d:\Program Files (x86)\WinRAR"
cd /d %1
set FILENAME=installer.%2.%3.%4.%5
if exist %FILENAME%.exe (
   del %FILENAME%.exe
)
%rarpath%\Rar.exe a -r -sfx -m5 -z"sfx.conf" %FILENAME% setup.exe oledb CEF UX  app.config.xml DrillDataAlys.exe  vcredist_x86.exe
