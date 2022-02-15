#!/usr/bin/perl

$logDir = "/var/adm";
chdir($logDir);
@logFiles = ("btmp", "btmps", "wtmp", "wtmps", "wtmpx");
$MAX_FILE_SIZE = 2000000;
$NUM_OF_LOGS = 10;
$NEW_FILE_SIZE = 0;

foreach $logFile (@logFiles)
{
        if(-f $logFile)
        {
                open(FILE, $logFile) or die "Cant open $logFile (line 12): $!\n";
                seek(FILE, 0, 2);
                $size = tell(FILE);
                close(FILE);
                if($size >= $MAX_FILE_SIZE)
                {
                        treatFile($logFile);
                }
        }
}

sub treatFile
{
        if(-f "$logFile.$NUM_OF_LOGS")
        {
                unlink("$logFile.$NUM_OF_LOGS");
        }
        for ($i=$NUM_OF_LOGS-1;$i > 0;$i--)
        {
                if(-f "$logFile.$i")
                {
                        $j = ($i + 1);
                        rename("$logFile.$i", "$logFile.$j");
                }
        }
        if (-f $logFile)
        {
                system("cp $logFile $logFile.1");
        }
        open(FILE, "+<$logFile");
        truncate(FILE, $NEW_FILE_SIZE);
        close FILE;
}
