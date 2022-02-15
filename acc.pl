#!/usr/bin/perl -w

use Net::Telnet ();
$ENV{'PATH'} = '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin';
$wd = "/wizard/users/acc/HESH/acc_menu9";
$dest_dir = "/home/baba";
$dest_user = "baba";

my @files = `find . \( -type d ! -name . -prune \) -o \( -name "STMT*" -print \)`;
for (my $i=0;$i<=$#files;$++) {
	zip $files[$i].zip $files[$i];
	scp $files[$i].zip $dest_user\@$host\:$dest_dir;
	ssh + checksum;
}

sub Sftp {

sftp <<EOF