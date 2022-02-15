#!/usr/bin/perl -w

@procStat = `psrinfo`;
foreach $proc (@procStat) {
	print "up\n" if $proc =~ /on-line/;
}

