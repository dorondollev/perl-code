#!/usr/bin/perl -w

use Getopt::Std;
getopts('w:c:');
unless ($opt_w && $opt_c || $opt_h)
{
        print "Unknown - ";
        &Help;
        exit 3;
}
if ($opt_h)
{
        &Help;
        exit 0;
}
$warn = $opt_w;
$crit = $opt_c;
$w = $c = 0;
@processes = `ps -eo 'time pid' | sort`;
for ($i=0; $i <= $#processes; $i++)
{
        chomp $processes[$i];
        if ($processes[$i] =~ /-/)
        {
                (@days) = split(/-/, $processes[$i]);
                (@pid) = split(/\s+/, $processes[$i]);
                if ($days[0] >= $warn)
                {
                        $warning{$pid[-1]} = $days[0];
                        $w++;
                }
                elsif ($days[0] >= $crit)
                {
                        $critical{$pid[-1]} = $days[0];
                        $c++;
                }
        }
}
if ($c)
{
        while (($key, $value) = each %critical)
        {
                print "The number of days process number $key has run is $value\n";
                $elapsDays = getElapsDays($key);
                if ($elapsDays - $value)
                {
                        $c--;
                }
        }
        if($c)
        {
                exit 2;
        }
}
elsif($w)
{
        while (($key, $value) = each %warning)
        {
                print "The number of days process number $key has run is $value\n";
                $elapsDays = getElapsDays($key);
                if ($elapsDays - $value)
                {
                        $w--;
                }
        }
        if($w)
        {
                exit 1;
        }
}
else
{
        exit 0;
}
sub getElapsDays
{
        $process = shift;
        $line = `ps -eo 'etime pid' | egrep $process | grep -v grep`;
        @numOfDays = split (/-/, $line);
        return $numOfDays[0];
}
sub Help
{
}
