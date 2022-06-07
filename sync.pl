#!/usr/bin/perl -w

@commands = (
                "/usr/bin/rsync -av --progress --delete prdzone1:/etc/lp/printers/ /prdzone1/users/doron/printers/",
                "/usr/bin/scp -p prdzone1:/etc/printers.conf /prdzone1/users/doron/"
);

$log = "/var/adm/syslog.dated/current/rsync.log";
open(LOG, ">$log");
$status = 0;
for($i=0; $i <= $#commands; $i++)
{
        @output = system($commands[$i] . " >> " . $log . " 2>&1" );
        print LOG @output;
        $exit = $?;
        $status += chkStatus($exit);
}
close(LOG);

mailAdmin($status, $log);

sub chkStatus
{
        $exit = shift;
        if($exit != 0)
        {
                return 1;
        }
        return 0;
}

sub mailAdmin
{
        $status = shift;
        $log = shift;
        open(LOG, "$log");
        if ($status > 0)
        {
                @subject = "rsync from prdzone1 to drpzone1 ended with $status errors";
        }
        else
        {
                @subject = "rsync  from prdzone1 to drpzone1 ended successfully";
        }
        $to = 'jimm@dow.gov.il';
        $from = 'john@dow.gov.il';

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