#!/usr/bin/perl -w

$ENV{'PATH'}='/bin:/sbin:/usr/bin:/usr/sbin:/usr/opt/networker/bin:/usr/local/bin';
$pool = "work daily full";
$client = "atlas";
@hp = ('BID', 'BPR', 'DVN', 'PRD', 'campaign', 'dwhetl', 'dwhrep', 'etlinfo', 'formit');
@sun = ('ams', 'ashrait', 'cti', 'ibms', 'inf', 'megaprod', 'oemdb', 'rbm', 'soloprod', 'unixdb', 'upsaleprod', 'wizard');
#mminfo -q \"group=$groupHours[0]\" -t \"$groupHours[1] hours ago\" -r client \| sort -u`;
for ($i=0;$i<$#hp;$i++) 
{
	for ($j=23;$j < 28;$j++) 
	{
		$day = $j;
		$day2 = $j+1;
		open(MMINFO, "mminfo -q \"client=olympus\" -q \"pool=Olympus Daily\" -q \'savetime>=08/$day/10\' -q \'savetime<=08/$day2/10\' -r name,sumsize,group,volume,savetime,volume|") or die "$!\n";
		while(<MMINFO>) 
		{
			chomp;
			if ($_ =~ /$hp[$i]/)
			{
				$redo = $arch = $data = 0;
				if ($_ =~ /redo/) {
					print "$1\n";
					print "redo: $_\n";
				}
#				elsif ($_ =~ /arch/) {
#					print "$1\n";
#					print "arch: $_\n";
#				}
#				elsif ($_ =~ /ctl/) {
#					print "$1\n";
#					print "ctl: $_\n";
#				}
#				elsif ($_ =~ mirr) {
#					print "$1\n";
#					print "mirr: $_\n";
#				}
#				elsif ($_ =~ /orig/) {
#					print "$1\n";
#					print "origlog: $_\n";
#				}
				else {
					print "$1\n";
					print "data $_\n";
				}
			}
		}
	}
}
