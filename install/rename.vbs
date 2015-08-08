Const TristateTrue = -1
Const ForReading = 1, ForWriting = 2, ForAppending = 8
Set objArgs = WScript.Arguments
If objArgs.Count=7 Then 
Dim fso, f
Set fso = CreateObject("Scripting.FileSystemObject")
rcfile = objArgs(0)&objArgs(1)&".rc"
rcbak = objArgs(0)&objArgs(1)&".rc.bak"
Set f = fso.OpenTextFile(rcfile, ForReading, True,TristateTrue)

Set regEx = New RegExp               ' 建立正则表达式。
tempfile = objArgs(0)&"temp.rc"
If fso.FileExists(tempfile) Then
  fso.DeleteFile tempfile
End If
Set f1 = fso.OpenTextFile(tempfile, ForWriting, True,TristateTrue)
            ' 设置模式。
regEx.IgnoreCase = True               ' 设置是否区分大小写。
regEx.Global = True               ' 设置是否区分大小写。
regEx.Pattern =  FormatRegVersion(objArgs(2))

do   until   f.AtEndOfStream
  line = f.ReadLine
  line = ReplaceVersion(regEx,line,objArgs(3),objArgs(4),objArgs(5),objArgs(6))  
  'WScript.Echo line
  f1.WriteLine line
loop   

While Not f.AtEndOfStream

Wend 
f1.Close
f.Close

If fso.FileExists(rcbak) Then
  fso.DeleteFile rcbak
End If

fso.CopyFile rcfile,rcbak,True
fso.CopyFile tempfile,rcfile,True
fso.DeleteFile tempfile
set   fso=nothing
End if



Function FormatRegVersion (version)
  FormatRegVersion = FormatRegStr(version, "\" &Chr(34)&", \"&Chr(34),".")  &"|"&  FormatRegStr(version," ",",")
End Function

Function FormatRegex (token)
  str="([\d]+(?:"&token&"[\d]+){3})"
  FormatRegex = str
End Function

Function FormatRegStr (version,delimeter,token)
  str = "(?:"& version&"VERSION"&delimeter&FormatRegex(token)&")" '
  FormatRegStr = str
End Function

FUNCTION ReplaceVersion(regEx,data,ver1,ver2,ver3,ver4)

  Set marches  = regEx.Execute(data)
    If  Not marches.Count=0  Then
       Set amatch=marches.Item(0)
      
      If   amatch.Submatches.Count>0  Then
        token = "."
      	Submar = amatch.Submatches(0)
      	If  Submar=Empty Then
        	token=","
        	Submar = amatch.Submatches(1)
      	End If 
          
       data = Replace(data,Submar,ver1&token&ver2&token&ver3&token&ver4)
      End if
   End If
   ReplaceVersion =data
   
End Function
