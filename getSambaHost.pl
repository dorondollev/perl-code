#!/usr/bin/perl -w

use Getopt::Std;

$ENV{'PATH'}='/bin:/sbin:/usr/bin:/usr/sbin:/usr/opt/networker/bin:/usr/local/bin:/usr/sfw/bin:/opt/samba/bin';

getopts('p:');

$dns = "10.10.10.30";
if (!$opt_p) {
	print "usage: getSambaHost.pl -p process_id\n";
	exit(1);
}
$process = $opt_p;
if (&itsProcess($process) == 1) {
	if (($ip=itsItSamba($process)) ne "0") {
		$os = `uname`;
		if ($os =~ /SunOS/) {
			print (getSunHost($ip));
			print "\n";
		}
		elsif ($os =~ /HP-UX/) {
			print (getHpHost($ip));
			print "\n";
		}
		else {
			print "Unsupported Operatin System: $os\n";
			exit(1);
		}
	}
	else {
		print "$process is not a samba process\n";
		exit(1);
	}
}
else {
	print "$opt_p is not a process\n";
	exit(1);
}

sub getHpHost {
	$ip = shift;
	if(($lookUp = `nslookup $ip $dns`) ne '\0') {
		@lines = split(/\s+/, $lookUp);
		return $lines[-3];
	}
	return 0;
}

sub getSunHost {
	$ip = shift;
	open(NAME, "nslookup $ip $dns|") or die "$!\n";
	while (<NAME>) {
		next if $_ !~ /in-addr.arpa/;
		@line = split(/\s+/, $_);
		chop($line[-1]);
		return $line[-1];
	}	
}

sub itsItSamba {
	$proc = shift;
	@getProc = `smbstatus 2>/dev/null`;
	foreach (@getProc) {
		next if $_ !~ /$proc/;
		@line = split(/\s+/, $_);
		return $line[2];
	}
	return "0";
}

sub itsProcess {
	$proc = shift;
	open(PS, "ps -ef|") or die "Can't execute: $!";
	while (<PS>) {
		if ($_ =~ /$proc/ && $_ !~ /$0/) {
			return 1;
		}
	}
	return 0;
}
