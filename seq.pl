#!/usr/bin/perl -w

use Getopt::Std;
#getopts('s:h');
my %opt;
getopts( 'hs:', \%opt );

$incremental = 1;

usage() if exists $opt{h};

if ($opt{s})
{
        $separator = $opt{s};
}
else
{
        $separator = "\n";
}

if ($#ARGV > 2)
{
        print "$0: Extra operand \`$ARGV[-1]\' \n";
        print "Try $0 -h\n";
        exit 1;
}
if ($#ARGV == 2)
{
        $incremental = $ARGV[1];
}
if ($#ARGV >= 1)
{
        $runner = $ARGV[0];
}
if ($#ARGV == 0)
{
        $runner = 1;
}
for($i=0; $i <= $#ARGV; $i++)
{
        if($ARGV[$i] ne $ARGV[$i] + 0)
        {
                print "Try $0 -h\n";
                exit 1;
        }
}

if ($#ARGV >= 0)
{
        $last = $ARGV[-1];
        while($runner <= $last)
        {
                print $runner;# . $separator;
                $runner += $incremental;
                if ($runner <= $last)
                {
                        print $separator;
                }
        }
        print "\n";
}

sub usage
{
        print "\t\tUsage: seq [OPTION]... LAST\n";
        print "\t\tor:  seq [OPTION]... FIRST LAST\n";
        print "\t\tor:  seq [OPTION]... FIRST INCREMENT LAST\n";
        print "\t\tPrint numbers from FIRST to LAST, in steps of INCREMENT.\n";
        print "\t\t-s \tuse STRING to separate numbers (default: \\n)\n";
}