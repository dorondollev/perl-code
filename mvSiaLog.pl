#!/usr/bin/perl -w

$ENV{'PATH'} = '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin';
$siaSyslog = "/var/adm/syslog.dated/current/sialog";
$sialog = "/var/adm/sialog";
$chkLogFile = &chkFile($siaSyslog);
print "Output of check log file: $chkLogFile.\n";
$chkSiaFile = &chkFile($sialog);
print "Output of check sia file: $chkSiaFile.\n";

if ( ($chkSiaFile == 0) && ($chkLogFile == 0) ) {
        system("/sbin/cat $sialog >>$siaSyslog");
} elsif ( ($chkSiaFile == 0) && ($chkLogFile > 0) ) {
        system("cp $sialog $siaSyslog");
}

if ($? == 0) {
        print "The content of $sialog copied to $siaSyslog\n";
        system("/sbin/cat /dev/null > $sialog");
        if (-z $sialog) {
                print "the content of $sialog deleted.\n";
        }
}

sub chkFile {
        $file = shift;
        system("ls $file");
                return $?;
}