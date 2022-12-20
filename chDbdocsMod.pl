#!/usr/bin/perl -w

use Cwd;
$workDir = "/dbdocs/prod";
print "Changing directory to $workDir\n";
chdir $workDir;
$dir = getcwd;
print "Dir is $dir\n";
if ($dir eq $workDir)
{
        system("chmod 444 *");
        if ($? == 0)
        {
                print "Changed mod read only to all files succesfuly\n";
        }
}
else
{
        print "Current dir isn\'t $workDir\n";
}