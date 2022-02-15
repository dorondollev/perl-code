#!/usr/bin/perl -wl

use Getopt::Std;
$ENV{'PATH'}='/bin:/usr/bin:/usr/local/bin:/usr/ucb:/usr/openwin/bin:/usr/sbin:
                /usr/ccs/bin:/etc:/opt/sfw/bin:/opt/Navisphere/bin:.';

($day, $month, $year, $hour, $min) = (localtime)[3, 4, 5, 2, 1];
$month += 1;
$year += 1900;
$date = "$year-$month-$day.$hour:$min";

getopts('mscht:d:');

if ($opt_h) {
	$opt_h = &Help;
} elsif (!$opt_d or $opt_d eq "") {
	$opt_h = &Help unless defined $opt_h;
	exit 1;
}

if ($opt_d) {
	$descriptor = $opt_d;
	$logfile = "$descriptor-$date.log";
	open(LOG, ">/usr/local/scripts/log/$logfile") or die "Cant open log file $logfile: $!";
	$ip = &IP($descriptor);
	$volumes = &Volumes($ip, $descriptor);
	(@volume) = split(/\n/, "$volumes");
	shift(@volume);
	print "The volumes are @volume";
	writeLog(0, "The volumes are @volume");
	($desc_name, $vol_name) = split(/-/, $volume[$#volume]);
	undef $vol_name;
	if ($desc_name !~ /\b$descriptor\b/) {
		writeLog(1, "The Copy Descriptor Name you have entered, Does not match instance conventional name!!!");
		die "\tThe Copy Descriptor Name you have entered
		Does\'nt match groups conventional name!!!\n";
	}
	print "The ip session is $ip";
	if ($ip eq '10.1.14.50') {
		$sp = 'A';
		writeLog(0, "The action should be on SP $sp");
		print "The action should be on SP $sp";
		} elsif ($ip eq '10.1.14.51') {
		$sp = 'B';
		print "The action should be on SP $sp";
		writeLog(0, "The action should be on SP $sp");
		}
}

if ($opt_m) {
	$opt_m = &MvLUN($descriptor, $sp);
}

if ($opt_c) {
	$opt_c = &Copy(@volume);
}

if ($opt_s) {
	if ($opt_t) {
        if (int($opt_t)) {
			$opt_s = &Status($opt_t, @volume);
		}
	} else {
		writeLog(1, "There is no time value using status interval of 30 seconds");
		print "There is no time value using status interval of 30 seconds";
		$opt_s = &Status('30', @volume);
	}
}

sub Copy {
	my @volume = @_;
	for ($i=0;$i<=$#volume;$i++) {
		if (!open(SANCOPY, "navicli -h $ip sancopy -start -name $volume[$i] &|")) {
			writeLog(2, "Cant start navicli: $!");
			die "Cant start navicli: $!";
		} 
		while (<SANCOPY>) {
			print "starting SAN Copy for $volume[$i]";
			writeLog(0, "Starting SAN Copy for $volume[$i]");
		}
	}
}

sub Status {
	my($time, @volume) = @_;
	while (@volume || exit 0) {
		for ($i=0;$i<=$#volume;$i++) {
			if (!open(STAT, "navicli -h $ip sancopy -info -name $volume[$i] -complete -sessionstatus -failure|")) {
				writeLog(2, "Cant get sancopy info: $!");
				die "Cant get sancopy info: $!";
			}
			print "starting status check for $volume[$i]";
			writeLog(0, "starting status check for $volume[$i]");
			while (<STAT>) {
				if ($_ =~ /Session Status/) {
					s/\s*//g;
					(@session) = split(/:/, $_);
					} elsif ($_ =~ /Percent Complete/) {
						s/\s*//g;
						(@percent) = split(/:/, $_);
						} elsif ($_ =~ /Failure Status/) {
							s/\s*//g;
							(@failure) = split(/:/, $_);
							}
			}
			if ($session[1] =~ /NotStarted/) {
				writeLog(3, "A SAN Copy for that instance never started");
				print "A SAN Copy for that instance never started.";
				splice(@volume, $i, 1);
				$time = '2';
			} elsif ($session[1] =~ /Complete/ && $failure[1] =~ /NoFailure/) {
				print "SAN Copy session for $volume[$i] finished";
				writeLog(1, "SAN Copy session for $volume[$i] finished");
				splice(@volume, $i, 1);
				if (!@volume) {
					$time = '2';
				}
			} elsif ($session[1] !~ /Complete/ && $failure[1] =~ /NoFailure/) {
				print "continue checking...";
				writeLog(0, "continue checking...");
				print "The session for volume $volume[$i] is now $session[1].";
				writeLog(0, "The session for volume $volume[$i] is now $session[1]");
				print "The precentage completed so far is $percent[1]%.";
				writeLog(0, "The precentage completed so far is $percent[1]%.");
				print "The session condition is in $failure[1] status.";
				writeLog(0, "The session condition is in $failure[1] status.");
			} elsif ($session[1] !~ /Complete/ && $failure[1] eq 'Failure') {
				writeLog(3, "SAN Copy for volume $volume[$i] failed: $!");
				die "SAN Copy for volume $volume[$i] failed: $!";
			}
		}
		if (@volume) {
			writeLog(0, "Waiting for $time seconds...\n\n");
			print "Waiting for $time seconds...\n\n";
			sleep $time;
#			&Clock($time);
		}
	}
}

sub Clock {
	my @time;
	$#time = shift or die "$!\n";
	$| = 1;
	@signs = ('|', '/', '-', '\\', '|', '/', '-', '\\', '|');
	for($i=0, $j=1;$j <= $#time;$i++, $j++) {
		print "$j\r\t";
		print "$signs[$i]\r";
		sleep 1;
		$i = '0' if $i == $#signs;
	}
}

sub MvLUN {
	($descriptor, $sp) = @_;
	@getlun = `navicli -h $ip getlun -name -owner | /bin/egrep '$descriptor|A|B|LOGICAL' | awk '{print \$NF}'`;
	if (!@getlun) {
		writeLog(2, "Cant get LUN trough navicli $!");
		die "Cant get LUN trough navicli $!";
	}
	for ($i=0;$i<=$#getlun;$i++) {
		if ($getlun[$i] =~ /$descriptor/) {
			$a = ($i - 1);
			$b = ($i + 1);
			chomp($getlun[$i]);
			chomp($getlun[$a]);
			chomp($getlun[$b]);
			print "The volume $getlun[$i] is on SP $getlun[$b] and LUN number $getlun[$a]";
			writeLog(1, "The volume $getlun[$i] is on SP $getlun[$b] and LUN number $getlun[$a]");
			if ($getlun[$b] !~ /$sp/) {
				if (!open(TRSPS, "navicli -h $ip trespass lun $getlun[$a] &|")) {
					writeLog(2, "navicli trespass lun $getlun[$a]: $!");
					die "Cant run navicli trespass lun $getlun[$a]: $!";
				}
				while (<TRSPS>) {
					print "moving LUN number $getlun[$a] to $ip";
					writeLog(1, "moving LUN number $getlun[$a] to $ip");
				}
			} else {
				print "LUN location is in the right place, and ready for SAN Copy";
				writeLog(0, "LUN location is in the right place, and ready for SAN Copy");
			}
		}
	}
}

sub IP {
	$descriptor = shift;
	$ip1 = '10.1.14.50';
	$ip2 = '10.1.14.51';
	$ip = $ip1;
$sc_info = `navicli -h "$ip" sancopy -info | grep $descriptor`;
if ($? == 256) {
	$ip = $ip2;
	}
undef $sc_info;
return "$ip";
}

sub Volumes {
	($ip, $descriptor) = @_;
	if (!open(CMD, "navicli -h $ip sancopy -info | grep $descriptor|")) {
		writeLog(2, "Cant run navicli sancopy info for $descriptor: $!");
		die "Cant run navicli sancopy info for $descriptor: $!";
	}
	while (<CMD>) {
		s/\s*//g;
		(@line)=split(/:/, $_);
		$volumes .= "\n$line[1]";
		}
	return $volumes;
}

sub Help {
	
	print "	\n\tsancopy.pl ver 1.0 written by Doron Dollev Feb 26 2006\n\n";
	print "\tsancopy.pl [-h] -d COPY_DESCRIPTOR_NAME [-m] [-c] [-s] [-t nnn]\n";
	print "\t-d		You must enter descriptor (instance) name.";
	print "\t-c		Start sancopy instance.";
	print "\t-m		Move LUNs to Session IP.";
	print "\t-s		Run status in a loop until sancopy for instance is finished.";
	print "\t-t		Create your prefered time interval in conjunction with status check (Deafult is 30 seconds).";
	print "\t-h		Print help screen.\n";
}

sub writeLog {
# get a message code and text
my $code = $_[0];
my $msg = $_[1];

# define numeric codes to message types
# update this list as you add message types
my @codeMap = ('Info', 'Notice', 'Alert', 'Error');

# map code to human readable message type
# Example: writeLog(4, "$ssid $pool");
my $msgType = $codeMap[$code];

# get current time
my $ts = localtime();

# create the log string and print it
print LOG "$ts $msgType $msg";
}

close(LOG);