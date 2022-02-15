#!/usr/bin/perl

use IO::Socket;
$bandwidth = 1024*1000; # 1000Kb/s
&send_file($ARGV[0], $ARGV[1]||'localhost', $ARGV[2]||6123);
exit;

sub send_file
{
        my($file, $host, $port) = @_;
        if (! -s $file)
        {
                die "ERROR! Can't find or blank file $file";
        }
        my $file_size = -s $file;
        my ($file_name) = ( $file =~ /([^\\\/]+)[\\\/]*$/gs );
        my $sock = new IO::Socket::INET(
                PeerAddr => $host,
                PeerPort => $port,
                Proto    => 'tcp',
                Timeout  => 30
        );

        if (! $sock)
        {
                die "ERROR! Can't connect\n";
        }
        $sock->autoflush(1);

        print "Sending $file_name\n$file_size bytes." ;

        print $sock "$file_name#:#" ; # send the file name.
        print $sock "$file_size\_" ; # send the size of the file to server.
        open (FILE,$file);
        binmode(FILE);
        my $buffer;

        while(sysread(FILE, $buffer, $bandwidth))
        {
                print $sock $buffer ;
                print "." ;
                sleep(1) ;
        }

        print "OK\n\n" ;

        close (FILE) ;
        close($sock) ;
}