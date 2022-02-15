#!/usr/bin/perl
use Date::Calc qw(Delta_Days Add_Delta_Days);

# function to write a line to the log
sub writeLog
{
# get a message code and text
my $code = $_[0];
my $msg = $_[1];

# define numeric codes to message types
# update this list as you add message types
#my @codeMap = ('', 'INFO', 'CRIT');
my @codeMap = ('', 'INFO', 'ACTN', 'UNDF', 'CRIT');

# map code to human readable message type
my $msgType = $codeMap[$code];

# get current time
my $ts = localtime();

# create the log string and print it
print LOG "$ts $msgType $msg\n";
}

# open log file for appending
#open(LOG, ">>/nsr/opt/sado/retent.log") or die "could not access retent.log: $!";
open(LOG, ">>retent.log") or die "could not access retent.log: $!";

# main script starts here
# load modular configuration pool context file
#$POOLS=("/nsr/opt/sado/recycle.cfg");
$POOLS=("recycle.cfg");
open(POOLS);
%pools=<POOLS>;
close(POOLS);

# treat each pool separately
# withdrawing the pools as keys and retention dates as values
foreach $pool (keys(%pools)) {
$offset = $pools{$pool};
chop $pool;

# mark the beginning of the log script execution for each pool.
writeLog(0, "-- BEGIN of Pool $pool --");

# Run a query command to get saveset information by sort by pool.
open(MM, "/usr/opt/networker/bin/mminfo -q \"pool=$pool\" -r 'savetime,ssretent,ssid'| /bin/grep -v ssid|");
while (<MM>) {

# Remove out put header
next if /\bssid\b/;

# Match the dates and ssid each field closed with ()
/(\d{2})\/(\d{2})\/(\d{2})\s*(\d{2})\/(\d{2})\/(\d{2})\s*(\d+$)/;

# Assign variables to each field
$m1=$1;
$d1=$2;
$y1=$3;
$m2=$4;
$d2=$5;
$y2=$6;
$ssid=$7;

# Define array to each scalar for later use
@start_date = ($y1, $m1, $d1);
@end_date = ($y2, $m2, $d2);

# Writing to log kind of treatment for the ssid
writeLog(0, "Taking care of ssid $ssid from pool $pool");
writeLog(0, "The savetime date is $m1/$d1/$y1\n");
writeLog(0, "The current expiration date is $m2/$d2/$y2");

# Getting the delta between savetime date and current retention definition and write it to log.
$delta = Delta_Days(@start_date, @end_date);
writeLog(0, "The delta is $delta days\n");

# Create saveset conditions treatments
if ($offset == $delta) {
        writeLog(1, "$ssid $pool\n");
        writeLog(0, "NO change has made to $ssid");
$mm=`/usr/opt/networker/bin/mminfo -q "ssid=$ssid" -r 'savetime,ssretent,ssbrowse,state,pool'`;
        writeLog(0, "$mm");
}
elsif ($offset < $delta) {

# If the offset definition is smaller then the current delta
# The module assigns the requested new delta to the scalars $year, $month and $day
# Last it uses nsrmm command to create a new retention -e and browse -w deffinitions.
        ($year, $month, $day) = Add_Delta_Days($y1, $m1, $d1, $offset);
$nsrmm=`/usr/opt/networker/bin/nsrmm -s atlas -S "$ssid" -w "$month/$day/$year" -e "$month/$day/$year"`;
$mm=`/usr/opt/networker/bin/mminfo -q "ssid=$ssid" -r 'savetime,ssretent,ssbrowse,state,pool'`;
        writeLog(2, "$ssid $pool\n");
        writeLog(0, "CHANGING rettention to $month/$day/$year\n");
        print "$nsrmm\n";
        writeLog(0, "$mm");

# If we reach the else condition somthing is wrong or abnormal and requires investigation.
                } else {
                writeLog(4, "$ssid $pool\n");
                writeLog(0, "Something is ABNORMAL\n");
                writeLog(0, "No change has made to $ssid, the output is: ");
$mm=`/usr/opt/networker/bin/mminfo -q "ssid=$ssid" -r 'savetime,ssretent,ssbrowse,state,pool'`;
                writeLog(0, "$mm");
                }
}
# Finish the specific pool logging
writeLog(0, "-- END of Pool $pool --");
}

close (LOG);