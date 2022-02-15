#!/usr/bin/perl -w

$logfile = "message.txt";
if (-e $logfile) {
	unlink $logfile;
}
open(LOG, ">>$logfile") or die "could not access $logfile: $!";
@coreFiles = &findCore;
if (@coreFiles) {
	foreach $cfile (@coreFiles) {
		chomp $cfile;
		next if (&chkCore($cfile) != 0);
		@ctime = &chkCTime($cfile);
		&destroy($cfile, $ctime[0]);
	}
	close(LOG);
	@message = &getMessage("$logfile");
	&sendMail;
	unlink $logfile;
}

sub destroy {
	($rmfile, $time) = @_;
	if ($time >= 4) {
		writeLog(0, "erasing $rmfile...");
		unlink $rmfile;
		writeLog($?, "done\n");
	}
}

sub chkCTime {
	$fcore = shift;
	$num_seconds = time - (stat($fcore))[9];
	$diff = $num_seconds;
	$seconds    =  $diff % 60;
	$diff = ($diff - $seconds) / 60;
	$minutes    =  $diff % 60;
	$diff = ($diff - $minutes) / 60;
	$hours      =  $diff % 24;
	$days = ($diff - $hours)   / 24;
	writeLog(0, "The file is $days days and $hours:$minutes:$seconds old");
	return($days, $hours, $minutes, $seconds);
}

sub chkCore {
	$corefile = shift;
	open(CORE, "file $corefile|") or die "could not execute $corefile: $!";
	while (<CORE>) {
		chomp;
		writeLog(0, "$_");
		if ($_ =~ /core/) {
			return 0;
		}
	}
	return 1;
}

sub findCore {
	return `find / -name core -type f`;
}

sub getMessage {
	$MESSAGE=shift;
	open(MESSAGE);
	@message=<MESSAGE>;
	close(MESSAGE);
	return @message;
}

sub writeLog {
	my $code = $_[0];
	my $msg = $_[1];
	my @codeMap = ('', 'INFO', 'ACTN', 'UNDF', 'CRIT');
	my $msgType = $codeMap[$code];
	print LOG "$msgType $msg\n";
}

sub sendMail {
	$host = `hostname`;
	my $sendmail = "/usr/sbin/sendmail -t";
	my $subject = "Subject: Core files on $host\n";
	#$send_to = "UnixStructure\@dbs.co.il";
	my $send_to = "dorond\@moia.gov.il\n";
	open(SENDMAIL, "|$sendmail $send_to") or die "Cannot open $sendmail: $!";
	print SENDMAIL $subject;
	print SENDMAIL @message;
	close(SENDMAIL);
}
