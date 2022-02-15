#!/usr/bin/perl -w

$logDir = "/usr/local/nagios/libexec/log";
$port = shift;
chomp($port);
@status = &portStat($port);
if ($status[0] eq '0')
{
        print "OK - no new errors\n";
        exit 0;
}
elsif($status[0] eq '1')
{
        print "Warning - ";
        printPort(@status);
        udpateLog(@status);
        exit 1;
}
else
{
        print "Critical - ";
        printPort(@status);
        udpateLog(@status);
        exit 2;
}

sub udpateLog
{
        @output = @_;
        if("$port.old.log")
        {
                @time = &getDate();
                open(LOG, ">$logDir/$port.@time.log") or die "Cant open log file $port.@time.log for write: $!\n";
        }
        else
        {
                system("cp $logDir/$port.log $logDir/$port.old.log");
                open(LOG, ">$logDir/$port.log") or die "Cant open log file $port.log for write: $!\n";
        }
        foreach (@output)
        {
                print LOG "$_\n";
        }
}

sub printPort
{
        @output = @_;
        foreach (@output)
        {
                s/^\s+//g;
                print "$_\n";
        }
}

sub matchLog
{
        $port = shift;
        $row = shift;
        open(ROWS, "$logDir/$port.log") or die "Cant open log file $port.log for read: $!\n";
        while(<ROWS>)
        {
                if ($_ =~ $row)
                {
                        @line = split;
                        close(ROWS);
                        return $line[-1];
                }
        }
}

sub compare
{
        $newValue = shift;
        $logValue = shift;
        if($logValue ne $newValue)
        {
                return 1;
        }
        return 0;
}

sub portStat
{
        $error = 0;
        $port = shift;
        open(FCSTAT, "/usr/sbin/fcinfo hba-port -l $port|") or die "fcinfo on port: $port isnt running\n";
        while (<FCSTAT>)
        {
                chomp;
                if ($_ =~ /State/)
                {
                        $state = $_;
                        $logValue = matchLog($port, 'State');
                        @line = split(/\s+/, $state);
                        $error += &compare($line[-1], $logValue);
                         if($error > 0)
                        {
                                return 2;
                        }
                }
                elsif ($_ =~ /Link Failure Count/)
                {
                        $LinkFailureCount = $_;
                        $logValue = matchLog($port, 'Link Failure Count');
                        @line = split(/\s+/, $LinkFailureCount);
                        $error += &compare($line[-1], $logValue);
                }
                elsif ($_ =~ /Loss of Sync Count/)
                {
                        $LossOfSyncCount = $_;
                        $logValue = matchLog($port, 'Loss of Sync Count');
                        @line = split(/\s+/, $LossOfSyncCount);
                        $error += &compare($line[-1], $logValue);
                }
                elsif ($_ =~ /Loss of Signal Count/)
                {
                        $LossOfSignalCount = $_;
                        $logValue = matchLog($port, 'Loss of Signal Count');
                        @line = split(/\s+/, $LossOfSignalCount);
                        $error += &compare($line[-1], $logValue);
                }
                elsif ($_ =~ /Primitive Seq/)
                {
                        $PrimitiveSeqProtocolErrorCount = $_;
                        $logValue = matchLog($port, 'Primitive Seq');
                        @line = split(/\s+/, $PrimitiveSeqProtocolErrorCount);
                        $error += &compare($line[-1], $logValue);
                }
                elsif ($_ =~ /Invalid Tx Word Count/)
                {
                        $InvalidTxWordCount = $_;
                        $logValue = matchLog($port, 'Invalid Tx Word Count');
                        @line = split(/\s+/,$InvalidTxWordCount);
                        $error += &compare($line[-1], $logValue);
                }
                elsif ($_ =~ /Invalid CRC Count/)
                {
                        $InvalidCRCCount = $_;
                        $logValue = matchLog($port, 'Invalid CRC Count');
                        @line = split(/\s+/,$InvalidCRCCount);
                        $error += &compare($line[-1], $logValue);
                }
        }
        close(FCSTAT);
        if($error > 0)
        {
                return ($state, $LinkFailureCount, $LossOfSyncCount, $LossOfSignalCount, $PrimitiveSeqProtocolErrorCount, $InvalidTxWordCount, $InvalidCRCCount);
        }
        return 0;
}

sub getDate
{
        return getTime('year') . "." . getTime('dom') . "." . getTime('month') . "." . getTime('hour') . "." . getTime('minute');
}

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
        elsif ($timeRequest eq 'dom') {
                return $localtime[3];
        }
        elsif ($timeRequest eq 'year') {
                return $year;
        }
}