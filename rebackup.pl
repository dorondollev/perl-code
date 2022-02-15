#!/usr/bin/perl -w

use Getopt::Long;
GetOptions("t:s", "s:s@");

if (defined(@opt_s)) {
	for ($i=0;$i<=$#opt_s;$i++) {
		$skippedHosts[$i] = $opt_s[$i];
	}
}

if ($opt_t) {
	$tape = $opt_t;
	open(MMINFO, "/usr/sbin/mminfo -q \"volume=$tape\" -r 'client,name' | egrep -v 'index|name'|") or die "$!";
	while (<MMINFO>) {
		chomp;
		($host, $mount) = split(/\s+/, $_);
		if (defined(@opt_s)) {
			for ($i=0;$i<$#opt_s;$i++) {
				print "$opt_s[$i]\n";
				next if $skippedHosts[$i] =~ $host;
#				print "Host is $host and mount is $mount\n";
			}
		} else {
			print "Host is $host and mount is $mount\n";
		}
	}
} else {
	print "\n\trebackup.pl ver 1.0 written by Doron Dollev Mar 27 2007\n\n";
	print "\trebackup.pl [-t volume] [-s Skipped_Host] -s Another_Skipped_Host]\n\n";
	print "\t-t		Name of failed volume you wish to reback it up (eg. U00039L2).\n";
	print "\t-s		Enter the host\\s name\\s you wish to avoid from unplaned database shutdown\n";
	print "\t		during current backup.\n";
	print "\n";
	print "\t	Example: rebackup.pl -t U00039L2 -s cratos -s ladonsap\n";
	print "\n";
	print "\t	Notice: rsh must work to all hosts listed on volume, for successfull backup\n";
	print "\n";
}

#sub chkRsh {
#	($host, $mount) = @_;
#	 system("/usr/bin/rsh $host ls $mount");
#	 if ($? > 0) {
#		 print "problem with rsh\n You better skip $host\n";
#		 exit 1;
#	 }
#	open(RSH, "/usr/bin/rsh $host ls $mount|") or die "problem with rsh: $!\n You better skip current host: $host\n";
#		while (<RSH>) {
#			if ($_ =~ /\bpermission denied\b/) {
#				print "$host cannot be accessed.\n You better skip current host: $host\n";
#				exit 1;
#			}
#		}
#}
