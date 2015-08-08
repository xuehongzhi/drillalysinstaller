@echo off
@setlocal EnableDelayedExpansion 
svn update .
for /F "eol=- usebackq tokens=1,2,* delims=r|" %%i in (`svn log -l 1`) do (
    if "!SVNVersion!" ==  "" (
	  set SVNVersion=%%i
	)
)
@echo !SVNVersion!