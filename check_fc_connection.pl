#!/usr/bin/perl -w

open(LUX, "luxadm -e port|") or die "Can't run luxadm: $!\n";
$status = 0;
while(<LUX>)
{
        $status += chkFc($_);
}
close LUX;
if ($status == 2)
{
        print "Critical - both fibers not connected\n";
        exit 2;
}
elsif ($status == 1)
{
        print "Warning - one fiber is not connected\n";
        exit 1;
}
else
{
        print "OK - everything is connected\n";
        exit 0;
}

sub chkFc
{
        $line = shift;
        @words = split(/\s+/, $line);
        if($#words > 1 && $words[1] eq 'NOT')
        {
                print "Critical - ";
                print "$line\n";
                return 1;
        }
        return 0;
}