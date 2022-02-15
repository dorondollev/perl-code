#!/usr/bin/perl -w

use Getopt::Std;

getopt('d');

if($opt_d)
{
        $device = $opt_d;
        $devFile = "$device";
}

$fileExist = 0;

if($status = isDeviceExist($device))
{
        ($device, $se, $he, $trn, $errors) = split(/\s+/, $status);
        $se = $he = $trn = 0;
        if($errors)
        {
                if(-f $devFile)
                {
                        $fileExist = 1;
                        $firstLine = readFirstLine($devFile);

                        if($errors > $firstLine)
                        {
                                unshiftNewErrorsToFile($devFile, $errors);
                                print "CRITICAL: More errors found in device $device";
                                exit 2;
                        }
                        if($errors == $firstLine)
                        {
                                if($days = isModifiedToday($devFile))
                                {
                                        if($days < 7)
                                        {
                                                print "Warn: $errors errors found in device $device";
                                                exit 1;
                                        }
                                        print "OK: A week ago there were $errors errors...\n The log is going to be deleted\n";
                                        exit 0;
                                }
                                print "CRITICAL: The $errors errors has been made today you need to take care of device: $device";
                                exit 2;
                        }
                }
                else
                {
                        writeFile($devFile, $errors);
                        print "CRITICAL: $errors errors found in device $device";
                        exit 2;
                }
        }
        print "OK: No errors in device $device";
        exit 0;
}
else
{
        if($fileExist)
        {
                unlink $devFile;
        }
        print "UNKNOWN: device $device doesn't exist";
        exit 3;
}

sub isModifiedToday
{
        $file = shift;
        $num_seconds = time - (stat($file))[9];
        $diff = $num_seconds;
        $seconds = $diff % 60;
        $diff = ($diff - $seconds) / 60;
        $minutes = $diff % 60;
        $diff = ($diff - $minutes) / 60;
        $hours = $diff % 24;
        $days = ($diff - $hours)   / 24;
        return $days;
}

sub unshiftNewErrorsToFile
{
        $file = shift;
        $error = shift;
        open(FH, "$file");
        @lines = <FH>;
        close(FH);
        open(FH,">$file");
        unshift @lines, $error;
        for($i=0; $i <=$#lines; $i++)
        {
                chomp $lines[$i];
                print FH "$lines[$i]\n";
        }
}

sub isDeviceExist
{
        $device = shift;
        @output = `iostat -e $device`;
        if($#output < 2)
        {
                print "UNKNOWN: device $device is missing\n";
                exit 3;
        }
        return $output[-1];
}

sub appendFile
{
        $file = shift;
        $content = @_;
        open(FH, ">>$file");
        print FH $content;
}

sub writeFile
{
        $file = shift;
        $content = $errors;
        open(FH, ">$file");
        print FH $errors;
}

sub readFirstLine
{
        $file = shift;
        open(FH, $file);
        @lines = <FH>;
        $line = shift@lines;
        return $line
}