#!/usr/bin/perl -w

use Getopt::Std;
getopts('hc:w:');

unless ($opt_w && $opt_c || $opt_h)
{
        print "Unknown - ";
        Help();
        exit 3;
}

if ($opt_h)
{
        &Help;
        exit 0;
}

$warn = $opt_w;
($w1, $w2, $w3)=split(/,/, $warn);
$crit = $opt_c;
($c1, $c2, $c3)=split(/,/, $crit);
$line = `uptime`;
chomp($line);
@state = split(/,\s+/, $line);
@part = split(/:\s+/, $state[-3]);
$s3 = $part[-1];
if(($w1 > $s3) && ($w2 > $state[-2]) && ($w3 > $state[-1]))
{
        print "OK - load average: $s3, $state[-2], $state[-1]";
        exit 0;
}

if(($c1 <= $s3) || ($c2 <= $state[-2]) || ($c3 <= $state[-1]))
{
        print "CRITICAL - load average: $s3, $state[-2], $state[-1]";
        exit 2;
}

print "WARNING - load average: $s3, $state[-2], $state[-1]";
exit 1;

sub Help
{
        print "USAGE: $0 -w warning_threshold -c critical_threshold\n";
}