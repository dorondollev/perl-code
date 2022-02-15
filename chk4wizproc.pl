#!/usr/bin/perl -w

$ENV{'PATH'} = '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin';

open(LOG, ">>wiz_process.log") or die "could not access wiz_process.log: $!";
open(TMP, ">>wizproc.tmp") or die "Can't write wizproc.tmp: $!\n";
#wizlckd => '3'
%process = (wizlckd => '4', wizsrv => '3', wizsrfl => '1',
           wir_pd_nds => '4', wir_rtr => '1', wir_sentinel => '1',
           wir_pur => '1', wir_dbserver_tcs => '1', wir_dbserver_tcs => '1', wir => '9',
           dmq => '13', wia_aru_interfac => '7', wia_router => '1', wia_db_server => '1',
           wia_ppv_server => '1', wia => '10');

#@rcpts = qw(wizardsupport@dbs.co.il it-operators@dbs.co.il danni.betzalel@convergys.com doron.dollev@dbs.co.il);
@rcpts = qw(doron.dollev@dbs.co.il);

while (($key, $value) = each %process) {
	$wizproc = chk4Proc($key, $value);
	if ($wizproc == '0') {
		writeLog(1, "$key process is OK");
	} else {
		$line = "The number of $key processes is $wizproc";
		writeTmp(2, "$line");
		writeLog(2, "$line");
	}
}

@prod7env = &getProd7env;
($add_abil_no, $legacy_no) = @prod7env;
writeLog(0, "RMI Address No is:$add_abil_no And Legacy No is: $legacy_no");
if ($add_abil_no && $legacy_no) {
	@rmi = &chkRmi();
	foreach (@rmi) {
		if ($_ =~ /A/) {
			(@AddAbility)=split(/ /, $_);
			shift(@AddAbility);
			$no_a = '2';#$#AddAbility + 1;
			if ($add_abil_no > $no_a) {
				writeLog(2, "RMI Addressability adapters are less then required: $_");
				writeTmp(2, "RMI Addressability adapters are less then required: $_");
			}
		} 
		if ($_ =~ /L/) {
			(@legacy)=split(/ /, $_);
			shift(@legacy);
			$no_l = '6';#$#legacy + 1;
			if ($legacy_no > $no_l) {
				writeLog(2, "RMI Legacy adapters are less then required: $_");
				writeTmp(2, "RMI Legacy adapters are less then required: $_");
			}
		}
	}
} else {
	writeLog(1, "Could not receive RMI adapters from prod7 environment.");
	writeTmp(1, "Could not receive RMI adapters from prod7 environment.");
}

&MailError();
`cat wiz_process.log`;

sub chkRmi {
	$user = 'prod7';
	$ENV{TERM} = "";
	STARTRMI: writeLog(0, "Starting RMI check");
	open(RMI, "su - $user -c '/wizard/prod7/bin/scripts/showRMIservers'|") or die "Cant get RMI servers information: $!";
	while (<RMI>) {
		next if $_ !~ /true|false/;
		if ($_ =~ /false/) {
			writeLog(1, "There is a false adapter: $_");
			sleep 40;
			$wait += 1;
			goto STARTRMI if $wait <= '4';
			writeTmp(2, "There is a false adapter: $_");
			writeLog(2, "$_");
		}
		if ($_ =~ /false/) {
			return $_;
		} else {
			@line=split(/\s+/, $_);
			if ($line[-1] eq 'A') {
				$existing_adressability .= " $line[-1]";
			} elsif ($line[-1] eq 'L') {
				$existing_legacy .= " $line[-1]";
			}
		}
	}

	if ($existing_adressability) {
		if ($existing_legacy) {
			writeLog(0, "Existing adressability adapters are: $existing_adressability.");
			writeLog(0, "Existing legacy adapters are: $existing_legacy");
			return ($existing_adressability, $existing_legacy);
		} else {
			writeLog(2, "There might be errors with adapters check for RMI existance.");
			writeTmp(2, "There might be errors with adapters check for RMI existance.");
			return 'error';
		}
	}
}

sub MailError {
	if (-z "wizproc.tmp") { print "wizproc.tmp is empty.\n"; }
	else {
		foreach (@rcpts) {
			system "cat wizproc.tmp | mailx -s 'Wizard Processes Problem' $_";
		}
	}
}

sub getProd7env {
	$user = 'prod7';
	$ENV{TERM} = "";

	$LOGNAME = `su - $user -c env | grep LOGNAME`;
	@logname = split(/=/, $LOGNAME);
	if ($logname[1] !~ /$user/) {
		writeLog(2, "Incorrect user self check\n");
		die "Incorrect user self check\n";
	}

	$MAX_ADDRESSABILITY_ADAPTERS = `su - $user -c env | grep MAX_ADDRESSABILITY_ADAPTERS`;
	@addressability_adapter_number = split(/=/, $MAX_ADDRESSABILITY_ADAPTERS);
	
	$MAX_LEGACY_ADAPTERS = `su - $user -c env | grep MAX_LEGACY_ADAPTERS`;
	@legacy_adapter_number  = split(/=/, $MAX_LEGACY_ADAPTERS);
	
	chomp($addressability_adapter_number[1], $legacy_adapter_number[1]);

	writeLog(0, "Reuired Addressability adapters: $addressability_adapter_number[1]");
	writeLog(0, "Required Legacy adapters: $legacy_adapter_number[1]");
	return ("$addressability_adapter_number[1]", "$legacy_adapter_number[1]");
}

sub chk4Proc {
	($key, $value) = @_;
	$ps = `ps -e | grep $key | grep -v grep | wc -l`;#| s/\s+/\s/;
	print "Value is $value\n";
	print "PS is $ps\n";
	if ($ps >= $value) {
		return '0';
	} else {
		return $ps;
	}
}

sub writeTmp {
	my $code = $_[0];
	my $msg = $_[1];
	my @codeMap = ('', 'INFO', 'CRITIC');
	my $msgType = $codeMap[$code];
	my $ts = localtime();
	print TMP "$ts $msgType $msg\n";
}

sub writeLog {
	my $code = $_[0];
	my $msg = $_[1];
	my @codeMap = ('', 'INFO', 'CRITIC');
	my $msgType = $codeMap[$code];
	my $ts = localtime();
	print LOG "$ts $msgType $msg\n";
}

#unlink "wizproc.tmp";