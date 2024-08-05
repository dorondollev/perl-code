#!/usr/bin/perl
use strict;
use warnings;
use MIME::Lite;

my @recipients = ('dorond@moia.gov.il', 'yedidyak@moia.gov.il', 'liore@moia.gov.il', 'shimic@moia.gov.il');
my $to = join(',', @recipients);
#my $to = 'dorond@moia.gov.il';
my $from = 'doron@orion.moia.gov.il';
my $logFile = "/var/log/syslog.dated/current/prdzone3_external.log";

open(LOG, ">>$logFile") or die "Could not open file: $logFile $!";

my $body = '';

my $exit=0;
my ($externalLabel) = getExternalDiskLabel();
if ($externalLabel)
{
    writeLog(0, "Label: $externalLabel");
    $body .= "<div style=\"text-align: left;\">Label: $externalLabel</div>";
}
else
{
    writeLog(3, "No external disk found");
    $body .= "<div style=\"text-align: left;\">No external disk found</div>";
    $exit=3;
}
my $path = getPath();
unless($path) {
    print "If you see this line, didn't find path\n";
    `udisksctl mount -b /dev/sdd1`;
    writeLog(3, "Path not found for label $externalLabel");
    $body .= "<div style=\"text-align: left;\">Path not found for label $externalLabel</div>";
    unless($exit) {
        $exit=1;
    }
}

if (-d $path) {
    writeLog(0, "my path is: $path");
    $body .=  "<div style=\"text-align: left;\">my path is: $path</div>";
} else {
    writeLog(1, "Could not locate mount");
    $body .= "<div style=\"text-align: left;\">Could not locate mount</div>";
    unless ($exit) {
        $exit=1;
    }
}

my $find_command = "find $path/prdzone3/archive -type f -mtime +30 -exec rm -f {} \\;";
my $exit_status = system($find_command);
if ($exit_status)
{
    my $num = $exit_status / 256;
    writeLog($num, "Couldnt erase file in $path/prdzone3/archive");
    $body .= "<div style=\"text-align: left;\">Couldnt erase file in $path/prdzone3/archive</div>";
}
else
{
    writeLog(0, "Cleaned more than 30 days old archive files in $path/prdzone3/archive");
    $body .= "<div style=\"text-align: left;\">Cleaned more than 30 days old archive files in $path/prdzone3/archive</div>";
}
$find_command = "find $path/prdzone3/weekly -type f -mtime +59 -exec rm -f {} \\;";
$exit_status = system($find_command);
if ($exit_status)
{
    writeLog($exit_status/256, "Couldnt erase file in $path/prdzone3/weekly");
    $body .= "<div style=\"text-align: left;\">Couldnt erase file in $path/prdzone3/weekly</div>";
}
else
{
    writeLog(0, "Cleaned more than 59 days old files in $path/prdzone3/weekly");
    $body .= "<div style=\"text-align: left;\">Cleaned more than 59 days old files in $path/prdzone3/weekly</div>";
}

my $presult = check_percentage($path);
if ($presult)
{
    writeLog(2, "Disk usage is greater than 95%");
    $body .= "<div style=\"text-align: left;\">Disk usage is greater than 95%</div>";
    unless ($exit) {
        $exit=2;
    }
}

my @commands = (
    #"/usr/bin/echo stam", "/usr/bin/echo nisayon", "/usr/bin/echo laasot", "/usr/bin/echo rsync"
    "/usr/bin/rsync -av --progress /archive/prdzone3/dbdocs/ $path/prdzone3/dbdocs/",
    "/usr/bin/rsync -av --progress /archive/prdzone3/yearly/month_out/ $path/prdzone3/month_out/",
    "/usr/bin/rsync -av --progress /archive/prdzone3/daily/archive/ $path/prdzone3/archive/",
    "/usr/bin/rsync -av --progress /archive/prdzone3/weekly/ $path/prdzone3/weekly/"
);

foreach my $command (@commands) {
    writeLog(0, "Currently running command: $command");
    $body .= "<div style=\"text-align: left;\">Currently running command: $command</div>";
    my $status = execute_command($command);
    if ($status > 0) {
        writeLog($status, "Error while running command $command");
        $body .= "<div style=\"text-align: left;\">Error while running command $command</div>";
    } else {
        writeLog(0, "Command $command ended successfully");
        $body .= "<div style=\"text-align: left;\">Command $command ended successfully</div>";
    }
    sleep(2);
}

# After all commands have been executed, send email with log file
my $subject = 'Backup to external disk finished';

# Send email
my $msg = MIME::Lite->new(
    From    => $from,
    To      => $to,
    Subject => $subject,
    Type    => 'text/html; charset=UTF-8',
    Data    => $body
);

$msg->send;

close(LOG);
exit $exit;

sub execute_command
{
    my $command = shift;
    my $status = system($command);
    return $status == 0 ? 0 : 1;
}

sub check_percentage
{
    my ($path) = @_;

    my @df_output = `df -l --output=pcent $path`;
    shift @df_output; # Remove header line

    foreach my $line (@df_output)
    {
        chomp $line;
        my ($percentage) = $line =~ /\s*(\d+)%/;
        if ($percentage && $percentage > 95)
        {
            return 1;
        }
    }
    return 0;
}

sub getPath
{
    my @df = `df -l --output=source,target|grep $externalLabel`;
    foreach my $line (@df) {
        chomp $line;
        my ($device, $path) = split(/\s+/, $line);
        if (defined $path) {
            return $path;
        } else {
            return "";
        }
    }
}

sub getExternalDiskLabel
{
    open (LSBLK, "lsblk -o NAME,LABEL,TRAN |") or die "Failed to run lsblk: $!";

    while (<LSBLK>)
    {
        chomp;
        my @line = split('\s+', $_);
        my $result = matchElement(@line);
        if ($result)
        {
            my $next_line = <LSBLK>;
            chomp($next_line);
            my @next_line_elements = split('\s+', $next_line);
            my $label = $next_line_elements[-1];
            return ($label);
        }
    }
}

sub matchElement
{
    my @array = @_;
    foreach my $element (@array)
    {
        if ($element eq 'usb')
        {
            return 1;
        }
    }
    return 0;
}

sub writeLog
{
    my $code = $_[0];
    my $msg = $_[1];
    my @codeMap = ('OK', 'WARNING', 'CRITICAL', 'UNKNOWN');
    my $msgType = $codeMap[$code];
    my $ts = localtime();
    print LOG "$ts $msgType - $msg\n";
}
