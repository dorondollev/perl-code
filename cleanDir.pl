#!/usr/bin/perl -w

use Cwd;
use Date::Calc qw(
	Time_to_Date
	Delta_Days
	);
$ENV{'PATH'}='/bin:/sbin:/usr/bin:/usr/sbin:/usr/opt/networker/bin:/usr/local/bin';
($day2, $month2, $year2) = (localtime)[3, 4, 5];
$month2 += 1;
$year2 += 1900;
$interval = 30;
$dir = "/wizard/oper7/work/yuval/post/bck";
use Cwd 'chdir';
chdir "$dir";
opendir(DIR, $dir) or die "Cant open $dir: $! \n";
@files = readdir(DIR);
foreach $file (@files) {
	next if $file !~ /dat$|gz$/;
	($sec, $min, $hour, $day1, $month1, $year1) = localtime((stat($file))[10]);
	$month1 += 1;
	$year1 += 1900;
	$Dd = Delta_Days($year1,$month1,$day1,$year2,$month2,$day2);
	if ($Dd >= $interval) {
		print "The file was created on: $file $day1-$month1-$year1 $hour:$min:$sec and the delta in days is: $Dd\n";
		if ($file !~ /gz$/) {
			print "I am gzipping $file\n";
			system("gzip $file");
		}
		if (-d "oldfiles" && $file =~ /gz$/) {
			print "moving $file to directory oldfiles\n";
			system("mv $file oldfiles");
		}
	}
	closedir(DIR);
}