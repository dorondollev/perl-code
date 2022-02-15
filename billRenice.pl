#!/usr/bin/perl

use Getopt::Std;
getopts('hp:n:');

$ENV{'PATH'}='/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin';

if ($opt_p || $opt_n) {
	$procnum = $opt_p;
	$nice = $opt_n;
	if (($procnum !~ /\d/) || ($procnum !~ /./) || ($procnum >= '9') || ($procnum <= '0') || ($nice >= '21') || ($nice <= '-21')) {
		print "\nThe process number or the nice flag is incorrect\n\n";
		&Help;
	} else {
		$process = '000' . "$procnum";
		$gfproc = &Ps('WIZ_SB_RUN_CYCLE_ASSESSOR.COM', "$process", '-2', '1');
		$fproc = &Ps('wiz_sb_assess_driver', $gfproc, '2', '1');
		$proc = &Ps('oracle', $fproc, '2', '1');
		&Renice($fproc, $nice);
		&Renice($proc, $nice);
	}
} elsif ($opt_h) {
	$opt_h = &Help;
} else {
	print "Nothing to do?\n";
}

sub Ps {
	($value1, $value2, $field, $return) = @_;
	open(PROC, "ps lax|grep $value1|") or die "Cant run command: $!\n";
	while (<PROC>) {
		split;
		next if $_ =~ /\bgrep\b/;
		next if $_ =~ /\bPID\b/;
		if ($_[$field] == $value2) {
			return $_[$return];
		}
	}
}

sub Renice {
	$procNumber = $_[0];
	$renice = $_[1];
	system("renice $renice -p $procNumber");
	&chkResult($procNumber, $renice);
}

sub chkResult {
	($procNumber, $renice) = @_;
	$result = &Ps($procNumber, $renice, '5', '5');
	if ($result == $renice) {
		print "The process $procNumber changed succesfully.\n";
	} else {
		print "Priority for process $procNumber is $_[5]\n";
	}
}

sub Help {
        print "\n\tbillRenice.pl ver 1.1 written by Doron Dollev Apr 18 2007\n\n";
        print "\tbillRenice.pl [-h] [-p process [-n prority]]\n\n";
        print "\t-p	Enter Billing's process number you wish to renice.\n";
		print "\t-n	Enter renice prefered priority, 20:lowest 0:normal -20:highest\n";
		print "\t-h	Print this help screen.\n\n";
		print "\t	Example: ./billRenice.pl -p 8 -n -20\n";
		print "\t	Notice: sudo user, consult your system admin for usage prior to operation.\n";
}
