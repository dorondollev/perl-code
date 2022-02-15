#!/usr/bin/perl -w

use POSIX;

if ($#ARGV != 1)
{
	Help();
	exit(1);
}
unless(@ARGV)
{
	Help();
	exit(1);
}

($procName, $numOfMinutes) = @ARGV;

unless (isnumber($numOfMinutes))
{
    print "error in minutes value\n";
    Help();
    exit(1);
}

open(PS, "ps -ef|") or die "error running command: $!\n";
while(<PS>)
{
	chomp();
    next if $_ =~ /$0/;
    next if $_ !~ /$procName/;
    @fields = split;
    if ($fields[4] =~ /[a-zA-Z]/)
    {
		push(@deathrow, $fields[1]);
    }
    elsif($fields[4] =~ /\b\d\d/)
    {
                @time = split(/:/, $fields[4]);
                $secondsSinceStart = checkTime(@time);
                @currentTime = ((localtime)[2], (localtime)[1], (localtime)[0]);
                $currentSeconds = checkTime(@currentTime);
                $diff = $currentSeconds - $secondsSinceStart;
                if ($diff < 0)
                {
                        $currentSeconds = $currentSeconds + 86400;
                        $diff = $currentSeconds - $secondsSinceStart;
                }
                $inMinutes = $diff / 60;
                if ($inMinutes > $numOfMinutes)
                {
                        push(@deathrow, $fields[1]);
                }
        }
}
kill 9, @deathrow;

sub Help
{
        print "USAGE: $0 <process_string_to_kill> <num_of_minutes>\n";
}

sub isnumber
{
    shift =~ /^-?\d+\.?\d*$/;
}

sub checkTime
{
        ($hour, $min, $sec) = @_;
        $mday = (localtime)[3];
        $mon = (localtime)[4];
        $year = (localtime)[5];
        $wday = (localtime)[6];
        $yday = (localtime)[7];
        $isdst = (localtime)[8];
        $unixtime = mktime ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst);
        return $unixtime;
}