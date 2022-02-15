#!/usr/bin/perl -w

use Getopt::Std;
getopt("dp");

$tmpDir = "/tmp";
unless ($opt_d && $opt_p && $opt_l)
{
    writeLog(1, "USAGE: $0 -d /full/path/to/pdf/file -p printer -l file.log");
    exit 1;
}
$printer = $opt_p;
$pdfFile = $opt_d;
$logFile = $opt_l;
open(LOG, ">>$logFile") or die "could not access $logFile: $!";
chdir($tmpDir);
open($_, $pdfFile) or die "Can't access pdf file: $pdfFile: $!";
chkPrinter($printer);
$status=`/usr/sfw/bin/pdf2ps $pdfFile >/dev/null 2>/dev/null`;
if($? > 0)
{
    writeLog(2, "error in transformation: $status\n");
}

@path = split(/\.|\//, $pdfFile);
$pf = "ps";
$psFile = "$path[-2]" . "." . "$pf";

$status=`lp -d$printer -o nobanner $psFile`;
if ($? > 0)
{
    writeLog(2, "error printing: $status\n");
}
unlink($psFile);
if(-e $psFile)
{
	writeLog(2, "error deleting file: $psFile");
}

sub chkPrinter
{
	$printer = shift;
    `lpstat -p $printer >/dev/null 2>/dev/null`;
    if($? > 0)
    {
		print "unknown printer: $printer\n";
		exit 1;
	}
}

sub writeLog
{
# get a message code and text
	my $code = $_[0];
	my $msg = $_[1];

# define numeric codes to message types
# update this list as you add message types
	my @codeMap = ('', 'INFO', 'ACTN', 'UNDF', 'CRIT');

# map code to human readable message type
	my $msgType = $codeMap[$code];

# get current time
	my $ts = localtime();

# create the log string and print it
	print LOG "$ts $msgType $msg\n";
}