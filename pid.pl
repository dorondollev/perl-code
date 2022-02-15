#!/usr/bin/perl -w

print "My process is: $$\n";
$PIDFILE = "/var/run/backup.pid";
if (-f $PIDFILE)
{
        open(PIDFILE);
        $pid=<PIDFILE>;
        close(PIDFILE);
        chomp $pid;
        print "backup.pid content: $pid\n";
        while($pid > 0)
        {
                open(PIDFILE);
                $pid=<PIDFILE>;
                close(PIDFILE);
                chomp $pid;
                print "PID: $pid\n";
                `ps -p $pid > /dev/null 2>&1`;
                $exit = $?;
                print "exit: $exit\n";
                if($exit == 0)
                {
                        print "sleeping...";
                        sleep 30;
                }
                else
                {
                        print "Process $pid is gone\n";
                        $pid = 0;
                }
        }
}
open(RUN, ">$PIDFILE") or die "Can't open $PIDFILE for write: $!\n";
print RUN $$;
close RUN;