#!/usr/bin/perl -w
# Perl built in module
# Accepting flags
use Getopt::Std;
# Make use of UNIX locking mechanism
use Fcntl 'LOCK_EX', 'LOCK_UN';
# create path environment
$ENV{'PATH'}='/bin:/sbin:/usr/bin:/usr/sbin:/usr/opt/networker/bin:/usr/local/bin';

# creating verbose date mechanism
($day, $month, $year, $hour, $min, $sec) = (localtime)[3, 4, 5, 2, 1, 0];
$month += 1;
$year += 1900;
$date = "$day-$month-$year.$hour:$min:$sec";

# flags declare
getopts('hdo:g:r:');
# directories variables declaration
$cronDir = "/app/cron";
#system("cd $cronDir");
chdir($cronDir);
$logDir = "$cronDir/log";
$currentCron = "/var/spool/cron/crontabs/root";
$cronUser = 'root';
$host = `/usr/bin/hostname`;
chomp($host);
$hostCron = "$cronDir/$host.cron";

# The following block runs the program:
# 1. checking the relevant flags
# 2. uses the relevant sub routines
# execute "./cronbuild.pl -h" for understanding flags and parameters behavior
if ($opt_h) {
        $opt_h = &Help;
} elsif (($opt_o) && (($opt_r) || ($opt_g))) {
        $option = $opt_o;
        if ($option !~ /add|del/) {
                print "You must enter 'add' or 'del' options.\n";
                &Help;
                exit 1;
        }
        if ($opt_r) {
                $group = $opt_r;
                if (&chkResourceState($group) !~ /ONLINE/) {
					if ($group !~ /$host/) {
						print "\nThe current resource group $group is not online on this node!!!\n";
						print "or\n";
						print "You are merging the wrong file.cron on host:$host!!!\n\n";
                        exit 1;
					}
                }
        } else {
                $group = $opt_g;
        }
        if (&chkFile("$cronDir/$group.cron") == 0) {
                &cronBuild($option, $group);
                if ($opt_d) {
                        &runDaemon($group);
                }
        } else {
                print "Cron file for group $group not exist.\n";
                exit 2;
        }
}

if (($opt_d)&&($opt_g)) {
        $group = $opt_g;
        $opt_d = &runDaemon($group);
}

# create a temporary cron file
system("/usr/bin/touch $cronDir/crontmp.$$");

# a void routine
# creates a new cronfile
# option - operation flag
# group - rg name
sub cronBuild {
        $option = $_[0];
        $group = $_[1];
        &lockFile();
        &appendFile2File($currentCron, "$logDir/$group.$$.$date"); #create history log file
        &cronBuildPrepare($option, $group);
        &addOthers($group);
        &newCronCreate();
        system("cat $cronDir/crontmp.$$");
        unlink("$cronDir/crontmp.$$");
        &unLockFile();
}

# Preparing temporary cron file structure
# creating a file containing desired updated groups
# action - add
# grp - rg name
sub cronBuildPrepare {
        $action = $_[0];
        $grp = $_[1];

        if ("$cronDir/$grp.cron" =~ /$hostCron/) {
        &appendFile2File($hostCron, "$cronDir/crontmp.$$");
        return;
        } else {
                &appendFile2File($hostCron, "$cronDir/crontmp.$$");
        }

        if ($action =~ /add/) {
                &appendFile2File("$cronDir/$grp.cron", "$cronDir/crontmp.$$");
        }
}

# filter current working resource group from other groups
# grp - rg name
sub addOthers {
        $grp = shift;
        @command = `/usr/cluster/bin/scha_cluster_get -O ALL_RESOURCEGROUPS`;
        for ($i=0;$i<=$#command;$i++) {
                if ($command[$i] =~ /\b$grp\b-rg/) {
                        splice(@command, $i, 1);
                }
        }

        foreach (@command) {
                chomp;
                print "Resource is: $_\n";
                @grps = split(/-/, $_);
                next if &chkResourceState($grps[0]) !~ /ONLINE/;
                if (chkFile("$cronDir/$grps[0].cron") == 0) {
                        &appendFile2File("$cronDir/$grps[0].cron", "$cronDir/crontmp.$$");
                } else {
                        warn "Cant append file: $cronDir/$grps[0].cron to template: $cronDir/crontmp.$$.\n";
                }
        }
}

# Checks resource group status
# return - ON if up, else OFF 
sub chkResourceState {
        $resource = shift;
        $grp = "$resource" . '-rg';
#       return `/usr/cluster/bin/scha_resource_get -O RESOURCE_STATE -R $resource -G $grp`;
        return `/usr/cluster/bin/scha_resourcegroup_get -O RG_STATE -G $grp`;
}

# create a temporary cron file
sub newCronCreate {
        system("su - $cronUser -c \"crontab $cronDir/crontmp.$$\"");
}

# creating appending writing mechanism
# fileRead - file to read from.
# fileWrite - file to append to.
sub appendFile2File {
        $fileRead = $_[0];
        $fileWrite = $_[1];
        open(FILEREAD, "< $fileRead") or die "Cant open $fileRead for read: $!\n";
        open(FILEWRITE, ">> $fileWrite") or die "Cant open $fileWrite for appen: $!\n";
        while (<FILEREAD>){
                print FILEWRITE;
        }
        close FILEWRITE;
        close FILEREAD;
}

# void command
# lock the file "cronbuild.lck" by current running program
sub lockFile {
        open(LOCK, ">$cronDir/$group.lck") or die "Cannot lock $group.lck - $!\n";
        flock(LOCK, LOCK_EX);
        seek (LOCK, 0, 2);
        print LOCK $$;
}

# void command
# release the file "cronbuild.lck" by current running program
sub unLockFile {
        flock(LOCK, LOCK_UN);
        close(LOCK);
}

# read from file and its contents
# file - file to read from.
sub getFileContent {
        $file = shift;
        open(FILE, "< $file") or die "Cant open $file: $!\n";
        while (<FILE>) {
                print;
        }
}

# check if file exist
# return - standard output status
sub chkFile {
        $file = shift;
        system("ls $file >/dev/null 2>&1");
        return $?;
}

# write into a file and erase its current contents
sub writeFile {
        $file = $_[0];
        $string = $_[1];
        open(FILE, "> $file") or die "Cant open $file: $!\n";
        print FILE $string;
        close FILE;
}

# print help to standard output
sub Help {
        print "\n\tcronbuild.pl ver 1.0 written by Doron Dollev Jun 18 2006\n\n";
        print "\tcronbuild.pl [-h] [-o <add|del> -r ResourceName]\n\n";
        print "\t-d(notice)     Daemon - For cluster use only.\n";
        print "\t-g(notice)     Resource group - For cluster use only.\n";
        print "\t-r             Name of resource instance.\n";
        print "\t-o             The options are 'add' or 'del'.\n";
        print "\t-h             Print this help screen.\n\n\n";
}

# run daemon by the cluster
sub runDaemon {
        $grp = shift;
        if (&chkFile("$cronDir/$grp.d") == 0) {
                exec("$cronDir/$grp.d");
        } else {
                print "Daemon file $cronDir/$grp.d not exist.\n";
        }
}

#system("cat $cronDir/cronbuild.lck");

# delete cron temporary file
unlink("$cronDir/crontmp.$$");