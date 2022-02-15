#!/usr/bin/perl -w
#
use Getopt::Std;

getopts('h:d:f:t:');

$ENV{PATH} = "$ENV{PATH}:/usr/local/backup/bin";

unless($opt_h && $opt_d && $opt_f && $opt_t)
{
        Help();
        exit 1;
}

$host = $opt_h;
$dir = $opt_d;
$file = $opt_f;
$target = $opt_t;

$uname = `ssh $host "uname" 2>/dev/null`;
if ($?)
{
        print "connection to $host failed\n";
        exit(2);
}
chomp($uname);
#chdir((@dir = $opt_d)) or die "Cant change dir to @dir: $!\n";
# cat prdzone1.backup_prd1_oradata.weekly.full.Sat.Nov.30.1_0.2013.tar.gz | ssh hrmzone1 "cd /recover; /usr/sfw/bin/gtar zxvf -"
chdir $dir or die "Cant change dir to $dir: $!\n";
@listOfFiles = `ls -1 -tr | grep $file`;
if ($?)
{
        print "Error finding file $file: $!\n";
        exit 2;
}
$ENV{TARGET} = $target;
$ENV{HOST} = $host;
$ENV{FILE} = $listOfFiles[-1];
system 'ssh $HOST "cd $TARGET && rm -rf $TARGET/*"';
if ($uname eq 'SunOS')
{
        $status = system '/bin/cat $FILE | ssh $HOST "cd $TARGET; /usr/sfw/bin/gtar zxvf -"';
}
elsif ($uname eq 'Linux')
{
        $status = system '/bin/cat $FILE | ssh $HOST "cd $TARGET; /bin/tar zxvf -"';
}

if ($?)
{
        print "Error secure extracting $listOfFiles[-1] to $host $target: $!\n";
        print "$status\n";
}

exit(0);

sub Help
{
        print "\t$0 <-h hostName> <-d /path/to/current/directory> <-f fileName> <-t /path/to/remote/dir>\n";
        print "\t-f : fileName may be partial, the $0 will use it as wild card to allocate the last one.\n";
}