@echo off
@setlocal EnableDelayedExpansion 
cd /d %~dp0
set PROGRAMDIR=%~dp0
set VC2012=
rem install vcredist
@echo install vcredist...
call :VCredistInstalled 
if "%VC2012%" == "" (
   vcredist_x86.exe
) else (
 @echo vcredist has been installed.
)
del /q vcredist_x86.exe
rem @echo %ERRORLEVEL%
if  %ERRORLEVEL% NEQ 0 goto end
rem install oracle oledb
@echo install oledb...
set oledb=false
call :OleDBInstalled
if "%oledb%" == "true" (
   @echo oracle has been installed.
) else (
	call :installOracle %1
	call :registerOracleEnv ORACLE_HOME %1
)
cd /d %PROGRAMDIR%
rmdir /s /q oledb
rem register environment

rem install drillanlys
rem xcopy /YIE program  %1
call :AddShortCut "%PROGRAMDIR%" DrillDataAlys "%PROGRAMDIR%DrillDataAlys.exe" 
set reboot = false
Echo wscript.Echo MsgBox ("安装程序要重启系统，是否重启", 36, "提示")>tmp.vbs
For /f %%i in ('cscript /nologo tmp.vbs') do If %%i==6 set reboot=true
Del /q tmp.vbs
if "%reboot%" == "true" (
   shutdown /r
)
goto end

:VCredistInstalled
set HKLMU=HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall
reg query %HKLMU%\{a55ac379-46b0-461a-95b1-fef5c08443f2}>nul 2>nul&&set VC2012=Microsoft Visual C++ 2012 Redistributable X86
if not "!VC2012!" == "" (
   exit /B 0
)
set HKLMU=HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall
reg query %HKLMU%\{a55ac379-46b0-461a-95b1-fef5c08443f2}>nul 2>nul&&set VC2012=Microsoft Visual C++ 2012 Redistributable X86
goto :eof

:AddShortCut
set dt=desktop
if not exist "%USERPROFILE%\%dt%" (
   set dt=桌面
)
set url= "%USERPROFILE%\%dt%\%2.lnk"
if exist %url% (
   del /q %url%
)
echo Dim WshShell,Shortcut>>tmp.vbs 
echo Dim path,fso>>tmp.vbs 
echo path=%3>>tmp.vbs 
echo Set fso=CreateObject("Scripting.FileSystemObject")>>tmp.vbs 
echo Set WshShell=WScript.CreateObject("WScript.Shell")>>tmp.vbs 
echo Set Shortcut=WshShell.CreateShortCut(%url%)>>tmp.vbs 
echo Shortcut.TargetPath=path>>tmp.vbs 
echo Shortcut.WorkingDirectory=%1>>tmp.vbs 
echo Shortcut.Save>>tmp.vbs 
"%SystemRoot%\System32\WScript.exe" tmp.vbs 
@del /f /s /q tmp.vbs  
goto :eof

:installOracle
cd /d oledb
call install.bat oledb %1 myhome true
goto :eof

:registerOracleEnv
set key="HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment"
reg add  %key% /v %1 /t REG_SZ /d "%2" /f
call :AddPathEnv %key% path "%2;%2\bin"
goto :eof

:AddPathEnv
set KEY_NAME=%1
set VALUE_NAME=%2
REM @for /F "tokens=1,2*" %%i in ('reg query "%1\SOFTWARE\Wow6432Node\Microsoft\VisualStudio\SxS\VS7" /v "11.0"') DO (
FOR /F "usebackq  tokens=1,2*" %%i IN (`REG QUERY %KEY_NAME% /v "%VALUE_NAME%"`) DO (
   set ValueValue=%%k
)
if defined ValueValue (
  set newPath=%3
  set newPath=!newPath:~1,-1!
  set newPath="!newPath!;%ValueValue%"
  echo !newPath!
  reg add  %KEY_NAME% /v %VALUE_NAME% /t REG_EXPAND_SZ /d ^!newPath^! /f
) else (
    @echo %KEY_NAME%\%VALUE_NAME% not found.
)
goto :eof
:OleDBInstalled
if defined ORACLE_HOME (
   set oledb=true
) else (
		call :TestOledb HKLM\SOFTWARE\Oracle
		if "%oledb%" == "false" (
			call :TestOledb HKLM\SOFTWARE\Wow6432Node\Oracle
		)
  )
)
goto :eof

:TestOledb 
set HKLMU=%1
set Oracle=
reg query %HKLMU%>nul 2>nul&&set Oracle=installed
if "%Oracle%" == "installed" (
	FOR  /F "usebackq" %%i IN (`reg query %HKLMU%`) DO (
		set olepath=%%i\oledb
		reg query !olepath!>nul 2>nul&&set oledb=true
		
	)  
)
goto :eof
:end
