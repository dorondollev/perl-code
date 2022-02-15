#!/usr/bin/perl -w

use Getopt::Std;
use Fcntl 'LOCK_EX', 'LOCK_UN', 'LOCK_NB';

getopts('j:');
if (! $opt_j) {
        die "You have to enter a job with its path: $!\n";
}

$jobfile = $opt_j;
$logfile = $jobfile . ".log";
$lockfile = $jobfile . ".lck";

open(LOG, ">>$logfile") || die "Cant open $logfile: $!\n";
writeLog(1, "locking $lockfile with process $$");
&lockFile($lockfile);

if (! -e $jobfile && ! -x $jobfile) {
        writeLog(2, "File $jobfile not exist nor executable");
}

writeLog(1, "start job $jobfile");
system("$jobfile");
writeLog(1, "finished job $jobfile");

close LOG;
&unLockFile();
exit 0;

sub lockFile {
        $lock = shift;
        open(LOCK, ">$lock");
        flock(LOCK, LOCK_EX|LOCK_NB) or die "$jobfile already running\n";
        seek (LOCK, 0, 2);
    print LOCK $$;
}

sub unLockFile {
    flock(LOCK, LOCK_UN);
    close(LOCK);
}

sub writeLog {
        my $code = $_[0];
    my $msg = $_[1];
    my @codeMap = ('', 'INFO', 'CRITIC');
    my $msgType = $codeMap[$code];
    my $ts = localtime();
    print LOG "$ts $msgType $msg\n";
}
