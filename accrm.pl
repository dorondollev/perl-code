#!/usr/bin/perl -w

use Getopt::Std;
getopts('f:');

$ENV{'PATH'} = '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin';

if ($opt_f) {
	if ($opt_f =~ /\bwebinv\b/) {
		&findWebinv;
	} elsif ($opt_f =~ /\bstmt\b/) {
		&findStmt;
	}
} else {
	&help;
}

sub findStmt {
	open(FIND, "find /wizard/prod7/data/reports -name \"STMT*\" -ctime \"+4\"|") or die "Can not execute find: $!\n";
	while (<FIND>) {
		chomp;
		&eraseFile($_);
	}
}

sub findWebinv {
	open(FIND, "find /wizard/users/acc -name \"webinv_*\" -ctime \"+4\"|") or die "Can not execute find: $!\n";
	while (<FIND>) {
		if (($_ =~ /final$/) || ($_ =~ /[0-1][0-9]$/)) {
			chomp;
			&eraseFile($_);
		}
	}
}

sub eraseFile {
	$file = $_;
	unlink $file;
	#system("ls -l $file");
	print "$file erased.\n";
}

sub help {
	print "\naccrm.pl ver 1.0 written by Doron Dollev Jul 25 2007\n\n";
	print "\taccrm.pl <-h> <-f file>\n\n";
        print "\t-f	Enter file instance: webinv or stmt\n";
		print "\t-h	Print this help screen.\n\n";
		print "\t	Example: ./accrm.pl -f webinv\n";
}
