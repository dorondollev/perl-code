#!/usr/bin/perl -w

$ENV{'PATH'} = '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin';
# creating verbose date mechanism
($day, $month, $year, $hour, $min) = (localtime)[3, 4, 5, 2, 1];
$month += 1;
$year += 1900;
$date = "$day-$month-$year\_$hour:$min";
$file = "/nsr/tmp/ssidForClone_$date";
open(SSIDFILE, ">>$file") or die "could not open $file: $!";
@mm = `mminfo -q "pool=ddpool" -t "22 hours ago" -q 'copies<2,pssid=0,!incomplete,!ssrecycle' -r ssid`;
for($i=0;$i<=$#mm;$i++) {
        chomp($mm[$i]);
        print SSIDFILE "$mm[$i]\n";
}
close SSIDFILE;
system("sh nsrclone -v -b Clone2w -S -f $file >>/nsr/logs/clone.log 2>&1");