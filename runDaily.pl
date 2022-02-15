#!/usr/bin/perl -w

use Fcntl 'LOCK_EX', 'LOCK_UN';

($day, $month, $year, $hour, $min, $sec) = (localtime)[3, 4, 5, 2, 1, 0];
$month += 1;
$year += 1900;
$date = "$day-$month-$year.$hour:$min:$sec";

&lockFile();
system("/soloprd/users/mtprod/runProcess.ksh 60 2 true");
system("/soloprd/users/mtprod/runProcess.ksh 70 2 true");
open(LOG, ">>/soloprd/users/mtprod/runDaily.log") || die "Cant open runDaily.log                                              : $!\n";
print LOG 'finish ';
print LOG "$date\n";
close LOG;
&unLockFile();
exit 0;

sub lockFile {
        open(LOCK, ">/soloprd/users/mtprod/runProcess.lck");
        flock(LOCK, LOCK_EX);
        seek (LOCK, 0, 2);
        print LOCK $$;
}

sub unLockFile {
        flock(LOCK, LOCK_UN);
        close(LOCK);
}