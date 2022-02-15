#!/usr/bin/perl -w

use Net::Telnet();

$networker_path = "/usr/opt/networker/bin";

MAIN: &mainMenu();
HOST: &hostMenu();
LEGATO: &legatoMenu();

sub legatoMenu {
	print "\n\nLegato Menu\n";
	print "\t1. Get hosts from group.\n";
	print "\t2. Get host mountes from backup group.\n";
	print "\t3. Return to Main Menu.\n";
	print "Select (1 2 3):   ";
	chomp($select = <>);
	if ($select == '1') {
		@groupHours = &subLegatoMenu('1');
		$hosts = `$networker_path/mminfo -q \"group=$groupHours[0]\" -t \"$groupHours[1] hours ago\" -r client \| sort -u`;
		print "\n\n$hosts\n";
		goto LEGATO;
	} elsif ($select == '2') {
		@hostGroupTime = &subLegatoMenu('2');
		$mminfo = `$networker_path/mminfo -q \"group=$hostGroupTime[1]\" -q \"client=$hostGroupTime[0]\" -t \"$hostGroupTime[2] hours ago\" -r name | sort -u | egrep -v \'index:|bootstrap\'`;
		print "\n\n$mminfo";
		goto LEGATO;
	} else {
		`clear`;
		goto MAIN;
	}
}

sub subLegatoMenu {
	$option = shift;
	if ($option == '1') {
		print "Please enter a valid group name: ";
		chomp($group = <>);
		$hours = &Hours();
		return($group, $hours);
	} elsif ($option == '2') {
		print "Please enter a valid host name: ";
		chomp($host = <>);
		print "Please enter a valid group name: ";
		chomp($group = <>);
		$hours = &Hours();
		return($host, $group, $hours);
	} else {
		`clear`;
		goto LEGATO;
	}
}

sub Hours {
	print "Please enter required number of hours [24 - default]: ";
	chomp($hours = <>);
	if ($hours !~ /[0-9]/) {
		$hours = '24';
		print "OK, then its 24 hours...\n";
		return int($hours);
	}
	print "You choosed $hours hours.\n";
	return int($hours);
}

sub mainMenu {
	print "\n\nMAIN Menu\n";
	print "\t1. Host menu.\n";
	print "\t2. Legato menu.\n";
	print "\t3. Exit.\n";
	print "Select (1 2 3):   ";
	chomp($select = <>);
	if ($select == '1') {
		goto HOST; 
	} elsif ($select == '2') {
		goto LEGATO;
	} elsif ($select == '3') {
		exit 0;
	} else {
		`clear`;
		goto MAIN;
	}
}

sub hostMenu {
	print "\n\nHost Menu\n";
	print "\t1. Get host currently mounts.\n";
	print "\t2. Return to Main Menu.\n";
	print "Select:  ";
	chomp($select = <>);
	if ($select == '1') {
		&getHostDf();
	} elsif ($select == '2') {
		goto MAIN;
	} else {
		print "You must choose between 1 or 2\n";
		goto HOST;
	}
}

sub getHostDf {
	print "Enter host ip: \n";
	chomp($host = <>);
	print "Enter operating system: \n";
	print '1. Tru64' . "\n";
	print '2. Solaris' . "\n";
	print '3. Linux' . "\n";
	print '4. Return to Host menu.' . "\n";
	print 'Select:  ';
	chomp($os = <>);
	print "\n\n";

	if ($os == '1') {
		$nf = "-1";
		$df = "df -t advfs,ufs";
		} elsif ($os == '2') {
			$nf = "0";
			$df = "df -l | grep dsk";
			} elsif ($os == '3') {
				$nf = "-1";
				$df = "df -x nfs -x tmpfs -x iso9660";
			} elsif ($os == '4') {
				goto HOST;
			}

	@lines = &netTelnet("$host", "$df");
	for ($i=0;$i<=$#lines;$i++) {
		chomp $lines[$i];
		next if $lines[$i] =~ /\bFilesystem\b/;
		@col = split(/ /, $lines[$i]);
		print "$col[$nf]\n";
	}
	goto HOST;
}

sub netTelnet {
($host, $command) = @_;
$username = 'sado';
$passwd = 'SadoMazo';
    $t = new Net::Telnet (Timeout => 10,
                          Prompt => '/\$/');
    $t->open("$host");
    $t->login($username, $passwd);
    @lines = $t->cmd("$command");
    return @lines;
}