#!/usr/bin/perl -w

$docsFile = "/dbdocs/docs.txt";
$logFile = "/var/adm/syslog.dated/current/updateDocsNtbg.log";
if (-f $docsFile)
{
        unlink($docsFile);
        $state = $?;
        if($state > 0)
        {
                print "CRITICAL - Could not remove $docsFile\n";
                exit ($state / 256);
        }
}

if ( -f "/usr/local/scripts/list_msm_dbdocs_nt.sh" )
{
        system("su - orafm -c \"/usr/local/scripts/list_msm_dbdocs_nt.sh\" | tee $docsFile $logFile 2>>$logFile >/dev/null");
        $status = $?;
        if ( $status > 0)
        {
                open(FH, $logFile) or die "$!\n";
                while(<FH>){print;}
                print "UNKNOWN - the above are unknown errors";
                exit 3;
        }
        open(my $fh, '<', $docsFile) or die "CRITICAL - Could not read file $docsFile $!";
        my @lines = <$fh>;
        close($fh);
        shift @lines;
        open($fh, '>', $docsFile) or die "CRITICAL - Could not write to file $docsFile $!";
        print $fh @lines;
        close($fh);
        $status = system("scp -p /dbdocs/docs.txt ntpzone1:/siren_nfs");
        if ($status == 0)
        {
                print "OK - $docsFile has created copied successfuly";
                exit 0;
        }
        else
        {
                print "CRITICAL - $docsFile was not nor copied to ntpzone1\n";
        }
}
else
{
        print "WARNING - file list_msm_dbdocs_nt.sh is missing can't continue";
        exit 1;
}
