#!/usr/bin/perl -w

use POSIX;
$sourceDir = "/dbdocs/prod";
$archive = "/dbdocs/prodh";
chdir($sourceDir);
$numberOfFiles = `ls | wc -l`;
print "Number Of Files in prod is $numberOfFiles\n";
$numberOfFilesToMove = $numberOfFiles - 100000;
print "Number Of Files To Move: $numberOfFilesToMove\n";
if ($numberOfFilesToMove <= 0)
{
        print "Files count is under 100000\n";
        exit 0;
}
@docs2mv = `ls | sort | head -$numberOfFilesToMove`;

foreach $doc (@docs2mv)
{
        chomp($doc);
        if ($doc =~ /(\d+)/)
        {
                $target = floor($1/100000);
                chomp $target;
                unless(-d "$archive/$target")
                {
                        chdir($archive);
                        print "Creating archive directory $target...\n";
                        mkdir($target, 0777) or die "Error creating directory: $!\n";
                        chdir($sourceDir);
                }
                print "moving $doc to $archive/$target\n";
                system("mv $doc $archive/$target/");
                if(-e "$archive/$target/$doc")
                {
                        print "Document $doc passed to $archive/$target/ successfuly\n";
                }
                else
                {
                        print "Document $doc didn't pass to $archive/$target/\n";
                }
        }
}