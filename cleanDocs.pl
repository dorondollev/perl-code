#!/usr/bin/perl
use strict;
use warnings FATAL => 'all';

my $docFilesList = "/siren_nfs/docs.txt";
my $ntprdDir = "/dbdocs/ntprd";
my $saveDir = "/dbdocs/saved/";
my $dbdocsDir = "/siren_nfs";
my $dh;
opendir($dh, $saveDir) or die "CRITICAL - Can't open directory $saveDir\n";
my @files = grep { !/^\.{1,2}$/ } readdir($dh);
closedir($dh);
if(@files)
{
    chdir($saveDir);
    foreach my $file (@files)
    {
        unlink $file or die "CRITICAL - Can't delete file: $file\n";
    }
}

open(LIST, $docFilesList) or die "CRITICAL - $docFilesList: $!";
my @list=<LIST>;
close(LIST);

chdir $ntprdDir or die "CRITICAL - $ntprdDir: $!";
my $mvFiles = "/tmp/listdDocs.txt";
if (-f $mvFiles)
{
    unlink($mvFiles);
}
my $missingFiles = "/tmp/missingDocs.txt";
if (-f $missingFiles)
{
    unlink($missingFiles);
}
my $foundFiles = "/tmp/foundDocs.txt";
if (-f $foundFiles)
{
    unlink($foundFiles);
}
open(FH, '>>',$mvFiles) or die "CRITICAL - Could not open $mvFiles $!\n";
open(FH2, '>>',$missingFiles) or die "CRITICAL - Could not open $missingFiles $!\n";
open(FH3, '>>',$foundFiles) or die "CRITICAL - Could not open $foundFiles $!\n";

for(my $i=0;$i <= $#list;$i++)
{
    chomp $list[$i];
    if( -f $list[$i])
    {
        print FH $list[$i];
        if (-d $saveDir)
        {
            system("cp -p $list[$i] $saveDir");
            if ($? > 0)
            {
                print "CRITICAL - Problem copying $list[$i] to $saveDir\n";
                exit 2;
            }
        }
        else
        {
            print "CRITICAL - Directory $saveDir not exist\n";
            exit 2;
        }
    }
    else
    {
        my $archDir = substr($list[$i], 0, 2);
        if( -d "$dbdocsDir/prodh/$archDir" )
        {
            if (-f "$dbdocsDir/prodh/$archDir/$list[$i]")
            {
                system("cp -p $dbdocsDir/prodh/$archDir/$list[$i] $saveDir");
                print FH3 "prodh/$archDir/$list[$i]\n";
            }
        }
        elsif (-f "$dbdocsDir/prod/$list[$i]" )
        {
            system("cp -p $dbdocsDir/prod/$list[$i] $saveDir");
            print FH3 "prod/$list[$i]\n";
        }
        else
        {
            print FH2 "$list[$i]\n";
        }
    }
}
my $seconds_since_epoch = time; # time in seconds since 1970
my $interval = 259200; # 3 days in seconds
opendir($dh, $ntprdDir) or die "CRITICAL - Can't open directory $ntprdDir\n";
@files = grep { !/^\.{1,2}$/ } readdir($dh);
closedir($dh);
if(@files)
{
    chdir($ntprdDir);
    foreach my $file (@files)
    {
        my $last_modified_time = fileTime($file);
        if (($seconds_since_epoch - $interval) > $last_modified_time)
        {
            unlink $file or die "CRITICAL - Can't delete file: $file\n";
        }
    }
}
close(FH);
close(FH2);
close(FH3);

system("mv $saveDir/* $ntprdDir/") == 0 or die "CRITICAL - Can't move files from $saveDir to $ntprdDir:$!";
print "OK - dbdocs NTBG cleanup finished successfuly\n";
exit 0;

if ( -s $missingFiles)
{
    system("mailx -s 'missing documents' dorond\@moia.gov.il < $missingFiles");
    system("mailx -s 'missing documents' elina\@moia.gov.il < $missingFiles");
}

sub fileTime
{
    my $filename = shift;
    my @file_info = stat($filename);
    return($file_info[9]);
}
