@echo off
@setlocal EnableDelayedExpansion 
if "%3"=="debug" goto :end
call :GetVersion
if not "%Install%"=="yes" goto :end

if not exist  %destpath%ux (
   mkdir %destpath%ux
)
if not exist  %destpath%cef (
   mkdir %destpath%cef
)
xcopy /YE %1ux  %destpath%ux
xcopy /YEIS  %1cef  /EXCLUDE:filter.txt %destpath%cef
copy  app.config.xml  %destpath%app.config.xml
copy  .\install\packt.bat  %destpath%packt.bat
copy  .\install\sfx.conf  %destpath%sfx.conf
copy  %1DrillDataAlys.exe  %destpath%DrillDataAlys.exe

set SVNNO=
call :GetSVN 

%destpath%packt.bat %destpath% %MajorVersion% %MinorVersion% %Version3% %SVNNO%

:GetSVN
svn update .
for /F "eol=- usebackq tokens=1,2,* delims=r|" %%i in (`svn log -l 1`) do (
    if "!SVNNO!" ==  "" (
	  set SVNNO=%%i
	)
)
goto :eof


:GetVersion
for /F "eol=- usebackq tokens=1,* delims==" %%i in (.\install\conf.txt) do (
   if "%%i" ==  "install" (
	  set Install=%%j
	) else (
				if "%%i" ==  "majorversion" (
			  set MajorVersion=%%j
			) else (
				if "%%i" ==  "minorversion" (
					set MinorVersion=%%j
				) else (
				    if "%%i" == "destpath" (
						set destpath=%%j
					) else (
					  if "%%i" == "stepversion" (
						set Version3=%%j
					)
					)					
	
				)
			)
	)
)
goto :eof
:end