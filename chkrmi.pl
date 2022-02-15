#!/usr/bin/perl -w

$ENV{'PATH'} = '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin';

open(LOG, ">>/usr/local/scripts/rmi_servers.log") or die "could not access rmi_servers.log: $!";

$legacy_adapter_env = &getEnv('env', 'MAX_LEGACY_ADAPTERS');
$legacy_adapter = &Split($legacy_adapter_env, '=', '1');
chomp($legacy_adapter);
writeLog(0, "Number of environment Legacy adapters are: $legacy_adapter");
$addressability_adapter_env = &getEnv('env', 'MAX_ADDRESSABILITY_ADAPTERS');
$addressability_adapter = &Split($addressability_adapter_env, '=', '1');
chomp($addressability_adapter);
writeLog(0, "Number of environment Addressability adapters are: $addressability_adapter");

FALSECHK: writeLog(0, "Check if false RMI adapters exist...");
$false = &getEnv('/wizard/prod7/bin/scripts/showRMIservers', 'false');
if ($false =~ /false/) {
        print "$false\n";
        $wait += 1;
        sleep 40;
        goto FALSECHK if $wait <= '4';
        writeLog(1, "False check exceeded 5 times");
        $msg = "False check exceeded 5 times\n";
} else {
        writeLog(0, "No false RMI adapters traced.");
}

$count_legacy_adapters = &getEnv('/wizard/prod7/bin/scripts/showRMIservers', 'L');
@converted_legacy_adapters = &Split($count_legacy_adapters, '\n');
$count_addressability_adapters = &getEnv('/wizard/prod7/bin/scripts/showRMIservers', 'A');
@converted_addressability_adapters = &Split($count_addressability_adapters, '\n');
@init_legacy_adapters = &FilterAdapters(@converted_legacy_adapters);
@init_addressability_adapters = &FilterAdapters(@converted_addressability_adapters);
if ($addressability_adapter > $#init_addressability_adapters) {
        writeLog(1, "There are less RMI Addressability adapters then required: $#init_addressability_adapters");
        $msg .= "There are less RMI Addressability adapters then required: $#init_addressability_adapters\n";
} else {
        writeLog(0, "The RMI Addressability adapters are just as required");
}

if ($legacy_adapter > $#init_legacy_adapters) {
        writeLog(1, "There are less RMI Legacy adapters then required: $#init_legacy_adapters");
        $msg .= "There are less RMI Legacy adapters then required: $#init_legacy_adapters\n";
} else {
        writeLog(0, "The RMI Legacy adapters are just as required");
}

if ($msg) {
        &MailError($msg);
} else {
	exit 0;
}

sub FilterAdapters {
        @array = @_;
        for ($i=0;$i<=$#array;$i++) {
                if ($array[$i] !~ /true|false/) {
                        splice(@array, $i, 1);
                }
        }
        return @array;
}

sub getEnv {
        $user = prod7;
        $ENV{TERM} = "";
        ($cmd, $var) = @_;
        $value = `su - $user -c '$cmd | grep $var'` or die "$!\n";
        if ($value ne "") {
                return $value;
        } else {
                return 'null';
        }
}

sub Split {
        ($obj, $delimiter, $index) = @_;
        @value = split(/$delimiter/, $obj);
        if (! $index) {
                return @value;
        } else {
                return $value[$index];
        }
}

sub writeLog {
        my $code = $_[0];
        my $msg = $_[1];
        my @codeMap = ('', 'INFO', 'CRITIC');
        my $msgType = $codeMap[$code];
        my $ts = localtime();
        print LOG "$ts $msgType $msg\n";
}

sub MailError {
        my $message = shift;
        my $sendmail = "/usr/lib/sendmail -t";
        my $subject  = "RMI servers problem";
        my @rcpts = qw(wizardsupport@dbs.co.il it-operators@dbs.co.il danni.betzalel@convergys.com doron.dollev@dbs.co.il);
		for ($i=0;$i<=$#rcpts;$i++) {
			open (SENDMAIL, "|$sendmail");
			print SENDMAIL "Subject: $subject\n";
			print SENDMAIL "From: doron\@wizard.dbs.co.il\n";
			print SENDMAIL "To: $rcpts[$i]\n\n";
			print SENDMAIL "$message\n";
			close(SENDMAIL);
		}
}