#!/usr/bin/perl

$ENV{'PATH'}='/bin:/sbin:/usr/bin:/usr/sbin:/usr/opt/networker/bin:/usr/local/bin';
$PARAMS=("oracle_kernel_param"); # written: first line: key, second line value
open(PARAMS);
%params=<PARAMS>;
close(PARAMS);
while (($key, $value) = each %params) 
{
	chomp $key;
	chomp $value;
	open(PROG, "kctune $key|") or die "$!\n";
	while(<PROG>) 
	{
		next if /\bTunable\b/;
		/(\S+)\s*(\S+)\s*(\S+)\s*(\S+)/;
		$K = $1;
		$V = $2;
		if($value <= $V) 
		{
			print "value: $V for $K is ok\n";
		}
        else 
		{
			print "value: $V in param $K need to be fixed to be at least: $value\n";
        }
	}
}