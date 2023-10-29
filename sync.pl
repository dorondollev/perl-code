#!/usr/bin/perl

use strict;
use warnings;

my @dir = (
    "/app/ntprd1/bin",
    "/app/ntprd1/forms",
    "/app/ntprd1/reports",
    "/dbdocs/ntprd"
);

my @commands = (
    `/usr/bin/rsync -av --progress ntpzone1:/app/ntprd1/bin/ /app/nthrm1/bin/`,
    `/usr/bin/rsync -av --progress ntpzone1:/app/ntprd1/forms/ /app/nthrm1/forms/`,
    `/usr/bin/rsync -av --progress ntpzone1:/app/ntprd1/reports/ /app/nthrm1/reports/`,
    `rsync -av --progress --delete ntpzone1:/dbdocs/ntprd/ /dbdocs/ntprd/`
);
my $state;
my $status = 0;
my $log = "/var/adm/syslog.dated/current/sync.log";

open(LOG, ">>$log") or warn("Can't open $log: $!\n");

for (my $i=0; $i <= $#dir; $i++) {
    $state = system("ssh ntpzone1 \"ls -ld $dir[$i]\"");
    if ($state > 0) {
        print LOG "Error ls dir $dir[$i]: $!\n";
        splice(@commands, $i, 1);
        $status++;
    }
}

my @output;

for(my $j=0; $j <= $#commands; $j++) {
    @output = $commands[$j];
    print LOG @output;
    @output = ();
}

close(LOG);
mailAdmin($status, $log);

sub mailAdmin
{
    my @subject;
    $status = shift;
    $log = shift;
    open(LOG, "$log");
    if ($status > 0)
    {
        @subject = "rsync from ntpzone1 to nthzone1 ended with $status errors";
    }
    else
    {
        @subject = "rsync  from ntpzone1 to nthzone1 ended successfully";
    }
    my $to = 'dorond@moia.gov.il';
    my $from = 'root@nthzone1.moia.gov.il';

    open(MAIL, "|/usr/sbin/sendmail -t");
    print MAIL "To: $to\n";
    print MAIL "From: $from\n";
    print MAIL "Subject: @subject\n\n";
    while(<LOG>)
    {
        chomp;
        print MAIL "$_\n";
    }
    close LOG;
    close MAIL;

    #unlink($log);
}
