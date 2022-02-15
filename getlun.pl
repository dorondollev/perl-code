#!/usr/bin/perl -wl
$ip = '10.1.14.50';
	@getlun = `navicli -h $ip getlun -name -owner | /bin/egrep 'ibmsnew|A|B|LOGICAL' | awk '{print \$NF}'` or die "$!\n";
	for ($i=0;$i<=$#getlun;$i++) {
		if ($getlun[$i] =~ /ibmsnew/) {
			print "$getlun[$i]";
			$a = ($i - 1);
			print "$getlun[$a]";
			$b = ($i + 1);
			print "$getlun[$b]";
			chomp($getlun[$a]);
			chomp($getlun[$b]);
			if ($getlun[$b] ne 'A') {
				open(TRSPS, "navicli -h $ip trespass lun $getlun[$a] &|") or warn "$!";
				while (<TRSPS>) {
					print "moving LUN number $getlun[$a] to $ip";
				}
			} else {
				print "LUN location is in correct place";
			}
		}
	}

print "hello";

#	$i = $#lun_no;
#	open(TRSPS, "navicli -h $ip trespass lun $lun_no[$i]|") or die "Cant execute $!\n $?\n";
#	while (<TRSPS>) {
#		$i--;
#	}
#} else {
#	undef($sp_lun);
#}