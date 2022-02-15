#!/usr/bin/perl -w

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