#!/usr/bin/perl -w
#
# last script updated in 8/3/2022
# in case you want to change the script
#
# N O T I C E
#=============
# both $drpzone1 = prdzone1 
# and $prdzone1 = prdzone1
# in zoneadmAction sub
# do not confuse between them

$dom = getTime('dom');
$mon = getTime('mon');
$year = getTime('year');
$errors = 0;

$logfile = "/var/log/syslog.dated/current/transSnapPrd2Drp.log";
open(LOG, ">$logfile") or die "$0 Can't open log file: $!\n";
open ( STDERR, ">>$logfile" );
open ( STDOUT, ">>$logfile" );
select( LOG );
$| = 1; # Turn on buffer autoflush for log output
select STDOUT;

$state = zoneadmAction("drpzone1", "list -p");
if ($state eq "running")
{
		print "Drpzone1 is $state\n";
}
else
{
		$errors++;
        print "Drpzone1 is $state\n";
        mailAdmin($errors);
        exit 1;
}
$state = zoneadmAction("prdzone1", "");
if ($state eq "running")
{
        print "Prdzone1 is $state\n";
}
else
{
		$errors++;
        print "Prdzone1 is $state\n";
        mailAdmin($errors);
        exit 1;
}
$state = zoneadmAction("drpzone1", "halt");
print "State output is: $state\n";
if ($state == 0)
{
        $state_1 = zoneadmAction("drpzone1", "list -p");
        if ($state_1 eq "installed")
        {
                print "Zone drpzone1 is down\n";
                print "Getting DRPZONE1os volume state\n";
                ($device, $stat) = getZpoolDevice();
                print "Zpool DRPZONE1os device is $device and its state is $stat\n";
        }
        else
        {
				$errors++;
                print "Something is wrong when getting info about device: $device nor state: $stat\n";
                mailAdmin($errors);
        }
}
else
{
		$errors++;
        print "problem stopping drpzone1\n";
        mailAdmin($errors);
        exit 1;
}

print "trying to destroy zpool DRPZONE1os\n";
system("zpool destroy DRPZONE1os");
$state = $?;
if ($state == 0)
{
        print "DRPZONE1os destroyed successfuly\n";
        if ($device)
        {
                print "trying recreate zpool DRPZONE1os...\n";
                system("zpool create DRPZONE1os $device");
                if ($? == 0)
                {
                        ($device, $status_1) = getZpoolDevice();
                        print "zpool DRPZONE1os created successfuly with device: $device and its state is: $status_1\n";
                }
                else
                {
						$errors++;
                        print "Couldn't create zpool DRPZONE1os\n";
                        mailAdmin($errors);
                }
        }
}
else
{
		$errors++;
        print "Couldn't destroy zpool DRPZONE1os\n";
        mailAdmin($errors);
}
print "Creating a snapshot on prdldg1\n";
system("ssh prdldg1 \"zfs snapshot PRDZONE1os\@$dom-$mon-$year.snap\"");
if($? == 0)
{
        print "zfs snapshot in prdzone1 for the date $dom-$mon-$year created successfuly\n";
}
else
{
        $errors++;
		print "zfs snapshot created with errors in prdzone1 for the date $dom-$mon-$year\n";
		mailAdmin($errors);
}
system("ssh prdldg1 \"zfs list PRDZONE1os\@$dom-$mon-$year.snap\"");
if ($? == 0)
{
        print "zfs snapshot PRDZONE1os\@$dom-$mon-$year.snap exist\n";
}
else
{
		$errors++;
        print "zfs snapshot PRDZONE1os\@$dom-$mon-$year.snap does not exist\n";
}
print "Starting zfs send prdldg1 to drpldg1\n";
system("ssh prdldg1 \"zfs send PRDZONE1os\@$dom-$mon-$year.snap\" | zfs recv -F DRPZONE1os");
if ($? == 0)
{
        print "snapshot from prdzone1 received to DRPZONE1os successfuly\n";
}
else
{
		$errors++;
        print "errors receiving snapshot from prdzone1 to DRPZONE1os\n";
		mailAdmin($errors);
}
system("zfs list DRPZONE1os");
if ($? == 0)
{
        print "snapshot DRPZONE1os exist\n";
}
else
{
        print "error snapshot DRPZONE1os does not exist\n";
		$errors++;
}

print "Trying to boot drpzone1...\n";
$status = zoneadmAction("drpzone1", "list -p");
if ($status eq "installed")
{
        print "Current status is: $status now can continue to boot\n";
}
else
{
        print "Don't know what to do next status is: $status\n";
}
$status = zoneadmAction("drpzone1", "boot");
if ($status > 0)
{
        print "Errors while trying to boot drpzone1\n";
}
else
{
        $status = zoneadmAction("drpzone1", "list -p");
        if ($status eq "running")
        {
                print "Job ended successfuly updated zone has been installed\n";
                mailAdmin(0);
                exit 0;
        }
        else
        {
                print "Job ended unsuccessfuly zone status is: $status\n";
                mailAdmin(1);
                exit 1;
        }
}

sub zoneadmAction
{
        $host = shift;
        print "Host is: $host\n";
        @action = @_;
        print "Action is: @action\n";
        if ( $host eq "prdzone1" )
        {
                $status = `ssh prdldg1 "zoneadm -z prdzone1 list -p"`;
        }
        else
        {
                $status = `zoneadm -z prdzone1 @action`;
        }
        if ($status)
        {
                chomp($status);
                @current = split(':', $status);
                return $current[2];
        }
        print "Action @action ended successfuly\n";
        return 0;
}

sub getZpoolDevice
{
        @str = `zpool status DRPZONE1os`;
        for ($i=0; $i <= $#str; $i++)
        {
                chomp($str[$i]);
                if ($str[$i] =~ m/c\dd\ds\d/)
                {
                        @line = split(/\s+/, $str[$i]);
                        @DRPZONE1os = ($line[1], $line[2]);
                }
        }
        return @DRPZONE1os;
}

sub mailAdmin
{
        $status = shift;
        if ($status > 0)
        {
                @subject = "prdzone1 zone transfer ended with errors";
        }
        else
        {
                @subject = "prdzone1 zone transfer ended successfuly";
        }
        $logfile = "/var/log/syslog.dated/current/transferPrdzone1Here.log";
        open(LOG, "$logfile");
        $to = 'dorond@moia.gov.il';
        $from = 'root@drpldg1.moia.gov.il';

        open(MAIL, "|/usr/sbin/sendmail -t");
        print MAIL "To: $to\n";
        print MAIL "From: $from\n";
        print MAIL "Subject: @subject\n\n";
        while(<LOG>)
        {
                chomp;
                print MAIL "$_\n";
        }
}
close LOG;
close MAIL;

sub getTime
{
        $timeRequest = shift;
        @months = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
        @weekDays = qw(Sun Mon Tue Wed Thu Fri Sat Sun);
        #($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = localtime();
        @localtime = localtime();
        $year = 1900 + $localtime[5];
        if ($timeRequest eq 'hour') {
                return $localtime[2];
        }
        elsif ($timeRequest eq 'minute') {
                return $localtime[1];
        }
        elsif ($timeRequest eq 'second') {
                return $localtime[0];
        }
        elsif ($timeRequest eq 'dow') {
                return $weekDays[$localtime[6]];
        }
        elsif ($timeRequest eq 'month') {
                return $months[$localtime[4]];
        }
        elsif ($timeRequest eq 'mon') {
                return $localtime[4] + 1;
        }
        elsif ($timeRequest eq 'dom') {
                return $localtime[3];
        }
        elsif ($timeRequest eq 'year') {
                return $year;
        }
}
