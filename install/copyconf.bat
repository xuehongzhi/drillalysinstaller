@echo off
@setlocal EnableDelayedExpansion 
set MajorVersion=
set MinorVersion=
set Version3=
set SVNVersion=
call :GetVersion
call :GetSVN
call wscript.exe  install\rename.vbs "%2" "%3" Product %MajorVersion% %MinorVersion% %Version3% !SVNVersion!
xcopy /YE ux\*  %1ux
copy  app.config.xml  %1app.config.xml
goto :end 

:GetSVN
svn update .
for /F "eol=- usebackq tokens=1,2,* delims=r|" %%i in (`svn log -l 1`) do (
    if "!SVNVersion!" ==  "" (
	  set SVNVersion=%%i
	)
)
goto :eof

:GetVersion
for /F "eol=- usebackq tokens=1,* delims==" %%i in (.\install\conf.txt) do (
    if "%%i" ==  "majorversion" (
	  set MajorVersion=%%j
	) else (
	    if "%%i" ==  "minorversion" (
			set MinorVersion=%%j
		) else (
		   if "%%i" ==  "stepversion" (
			   set Version3=%%j
			)
		)
	)
)
goto :eof

:end
