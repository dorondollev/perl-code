#!/usr/bin/perl

use IO::Socket;
use Win32;
use Win32::Process;
use Win32::Process (STILL_ACTIVE);

my $port = $ARGV[0] || 6123;

my $server = IO::Socket::INET->new
(
    Listen => 5,
    LocalAddr => '10.30.1.232',
    LocalPort => $port ,
    Proto     => 'tcp'
) or die "Can't create server socket: $!\n";

print "Server opened: localhost:$port\nWaiting clients...\n\n";

while(my $client = $server->accept)
{
	print "\nNew client!\n" ;
    my ($buffer, %data, $data_content);
    my $buffer_size = 1;

    while( sysread($client, $buffer , $buffer_size) )
    {
		if ($data{filename} !~ /#:#$/)
        {
			$data{filename} .= $buffer;
		}
        elsif ($data{filesize} !~ /_$/)
        {
			$data{filesize} .= $buffer ;
        }
        elsif ( length($data_content) < $data{filesize})
        {
			if ($data{filesave} eq '')
            {
				$data{filesave} = "$data{filename}";
                $data{filesave} =~ s/#:#$//;
                $buffer_size = 1024*10;
                if (-e $data{filesave})
                {
					unlink ($data{filesave});
                }
                print "Saving: $data{filesave} ($data{filesize}bytes)\n";
            }
            open (FILENEW,">>$data{filesave}");
            binmode(FILENEW);
            print FILENEW $buffer;
            close (FILENEW);
            print ".";
        }
        else
        {
			last;
        }
    }

	Win32::Process::Create($ProcessObj, "C:\\Reader\\AcroRd32.exe",  "AcroRd32 /h /p $data{filesave}", 0, NORMAL_PRIORITY_CLASS, ".") || die ErrorReport();
	$pid = $ProcessObj->GetProcessID();
	print "PID: $pid\n";
	$ProcessObj->Wait(10000);
	$ProcessObj->GetExitCode($exitcode);
	print "Exit code is: $exitcode\n";
	if($exitcode == 0)
	{
		print "Exiting normally\n";
	}
	elsif($exitcode == STILL_ACTIVE)
	{
		print "Killing AcroRd32 active process\n";
		$ProcessObj->Kill(59);
	}
	else
	{
		print "AcroRd32 exited abnormally\n";
	}
	unlink ($data{filesave});
	print "OK\n\n";
}

sub ErrorReport
{
	print Win32::FormatMessage(Win32::GetLastError() );
}
