#!/usr/bin/perl

$seconds = (localtime)[0];
$minutes = (localtime)[1];
$hour = (localtime)[2];
print "$hour:$minutes:$seconds\n";
$dayofmonth = (localtime)[3];
$l444 = (localtime)[4];
$month = $l444 + 1;
$l555 = (localtime)[5];
$year = $l555 + 1900;
print "$dayofmonth $month $year\n";


# the backwords way:
use POSIX;
$sec  = 45;
$min = 5;
$hour = 9;
$mday = (localtime)[3];
$mon = (localtime)[4];
$year= (localtime)[5];
$wday=(localtime)[6];
$yday=(localtime)[7];
$isdst=1;
$unixtime = mktime ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst);
print "$unixtime\n";
# the output is: 1376467632