#!/usr/bin/perl -w

print "switching loghost to drpzone1...\n";
$in = "/DRPZONE1os/root/etc/inet/hosts";
$out = "hosts.new";
open (IN, '<', $in) or die "Can't read old file: $!";
open (OUT, '>', $out) or die "Can't write new file: $!";

while( <IN> )
{
        chomp;
        if ($_ =~ m/loghost$/)
        {
                @line = split(/\s/, $_);
                $two_words = join '      ', $line[0], $line[1];
                print OUT "$two_words\n";
        }
        elsif ($_ =~ m/drpzone1/)
        {
                $new_line = join '      ', $_, "loghost";
                print OUT "$new_line\n";
        }
        else
        {
                print OUT "$_\n";
        }
}
close OUT;
close IN;
$in = "hosts.new";
$out = "/DRPZONE1os/root/etc/inet/hosts";
print "Moving $in file to $out file\n";

open (IN, '<', $in) or die "Can't read old file: $!";
open (OUT, '>', $out) or die "Can't write new file: $!";

while( <IN> )
{
        chomp;
        print OUT "$_\n";
}
close OUT;
close IN;
unlink($in);

$nodename = "/DRPZONE1os/root/etc/nodename";
if (-f $nodename)
{
        open (NODENAME, ">$nodename") or die "Can't open $nodename for write: $!\n";
        print NODENAME "drpzone1";
}
else
{
        print "No nodename file: $nodename\n";
        mailAdmin(1);
}
