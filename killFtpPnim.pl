#!/usr/bin/perl -w

$process = `pgrep send_ftpnim.sh`;
if ($process eq "")
{
        exit 0;
}
$etime = `ps -o etime= -p $process`;
@time = split(/\s+|\n|\t/,$etime);
shift(@time);
($h, $m, $s) = split(/:/, $time[0]);
print "<$h><$m><$s>\n";
if ($s)
{
        print "s is $s\n";
}
else
{
        #print "h should b terminated\n";
        $s = $m;
        $m = $h;
        $h = 0;
}
print "<$h><$m><$s>\n";
if($h > 0)
{
        print "killing send_ftpnim.sh for running over 1 hour...\n";
        `kill -9 $process`;
        print "done.\n";
        exit 0;
}
elsif($m > 10)
{
        print "killing send_ftpnim.sh for running over a 30 minutes...\n";
        `kill -9 $process`;
        print "done.\n";
        exit 0;
}