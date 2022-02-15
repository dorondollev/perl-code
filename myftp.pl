#!/usr/bin/perl -w

use Getopt::Std;
use Net::FTP;

getopts('hl:d:u:p:f:a:');

if ($opt_h) {
        $opt_h = &Help;
        exit(0);
}
if ($opt_l) {
        $local_dir = $opt_l;
}
else {
        $local_dir = ".";
}
chdir($local_dir);

if ($opt_f) {
        $put_file = $opt_f;
}
else {
        print "You must enter a file name for upload\n";
        &Help;
}

if ($opt_d) {
        $dest_dir = $opt_d;
}
else {
        $dest_dir = ".";
}

if ($opt_a) {
        $host = $opt_a;
}
else {
        print "You must enter a host name destination\n";
        &Help;
}

if ($opt_u) {
        $user = $opt_u;
}
else {
        $user = "anonymous";
        print "user is anonymous\n";
}

if ($opt_p) {
        $password = $opt_p;
        print "$password\n";
}
else {
        $password = "anon\@";
}
my $f = Net::FTP->new($host) or die "Can't open $host\n";
$f->login($user, $password) or die "Can't log $user in: $f->message\n";
$f->binary();
$f->cwd($dest_dir) or die "Cannot change working directory ", $f->message;
$f->put($put_file) or die "Can't put $put_file: $f->message\n";
$f->ls;
$f->quit;

#$, = "\n";
#my @dest_files = $f->list;
#print @dest_files, "\n";

sub Help {
        print "\n\tmyftp.pl ver 1.0 written by Doron Dollev Feb 02 2011\n\n";
        print "\tmyftp.pl [-h] [-l /path/to/local/dir] -f <file> [-d destination dir] -a <address> [-u user] [-p password]\n\n";
        print "\t-h\tPrint this help screen.\n";
        print "\t-l\tOptional, enter local directory. if not defined consider local directory\n";
        print "\t-d\tOptional, enter destination directory if not defined consider login directory\n";
        print "\t-f\tFile name for tranfer. This option is required.\n";
        print "\t-u\tEnter user name, if none anonymous will be used instead.\n";
        print "\t-p\tPassword must be between apostrophe's: 'password'. Or you may suffer from special characters errors\n";
}