#!/usr/bin//perl -w
use strict;
use Date::Manip qw(ParseDate DateCalc);
use Net::Telnet ();
use vars qw($nr $nf @hosts $i $mminfo @lines $cmd $df @mounts $NF
			$line $username $passwd $q1 $t $host $mount @array
			$group $pool $hours $clients @servers $lines $name
			@uname $ENV $command $q $r1 $r2 $uname $i $hosts);
$ENV{'PATH'}='/bin:/sbin:/usr/bin:/usr/sbin:/usr/opt/networker/bin:/usr/local/bin';
$group=shift;
$hours = lastStart("$group");
print "$hours\n";
#$pool = Group2Pool();
@hosts = `mminfo -s atlas -q "group=$group" -t $hours -r client | sort -u`;
print "$pool\n";
#$nr = $.;
	$username = 'sado';
	$passwd = 'SadoMazo';

for ($i=0;$i<=$#hosts;$i++) {
	chomp($hosts[$i]);
    $t = new Net::Telnet (Timeout => 10,
                          Prompt => '/\$/');
    $t->open("$hosts[$i]");
    $t->login($username, $passwd);
    $cmd = 'uname';
	@uname = $t->cmd($cmd);
	chomp(@uname);
	$uname = @uname;
	print "$uname\n";
	if ($uname =~ m/OSF1/) {
		$df = 'df -t advfs,ufs';
	} elsif ($uname =~ m/SunOS/) {
		$df = 'df -l | grep dsk';
	} elsif ($uname =~ m/Linux/) {
		$df = 'df -lT | grep ext';
	} else {
		print "OS is undefind\n";
	}
	print "$df\n";
#	@mounts = $t->cmd($df);
	$t->close;
}

#$host = shift;
#$command = shift;
#&net_telnet($host, $command);
#
sub net_telnet {
	$host = shift;
	$username = 'sado';
	$passwd = 'SadoMazo';
    $t = new Net::Telnet (Timeout => 10,
                          Prompt => '/\$/');
    $t->open("$host");
    $t->login($username, $passwd);
    $cmd = 'uname';
	@array = $t->cmd($cmd);
	print @array;
}
#}

sub lastStart {
$group = shift;
open(TEMP, ">>$group.temp") or die "Can't open $group.temp for appen: $!\n";
print TEMP "show last start\n";
print TEMP ". type:NSR group; name: $group\n";
print TEMP "print\n";
close(TEMP);
my $last_start = `nsradmin -s atlas.dbs.co.il -i $group.temp`;
unlink "$group.temp";
(my @date_then) = split(/"/, $last_start);
my $date_cur = `/bin/date`;
my $d1 = ParseDate("$date_then[1]");
my $d2 = ParseDate("$date_cur");
my $date_diff = DateCalc($d1, $d2);
(my @data) = split(/:/, $date_diff);
if ($data[-3]) {
        my $hour = $data[-3] + 1;
        return "$hour";
        }
}

#sub Group2Pool {
#open(TMP, ">>$group.tmp") or die "Can't open $group.tmp for appen: $!\n";
#print TMP ". type: nsr pool; groups: $group\n";
#print TMP "show name\n";
#print TMP "print\n";
#close(TMP);
#@lines = `nsradmin -s atlas.dbs.co.il -i $group.tmp`;
#foreach $line (@lines) {
#chomp $line;
#next if $line !~ /name/;
#my($trash, $name)=split(/: /, $line);
#my($pool, $nothing)=split(/;/, $name);
#return $pool;
#}
#}

#my(@client)=split(/;/, $name_client_scolon[1]);
#$host .= ":$client[0]";
#}
#return $host;
#sub OS_Uname {
#	$uname = shift;
#	if ($uname =~ m/OSF1/) {
#		$nf = "-1";
#		} elsif ( $name =~ m/SunOS/) {
#			$nf = "0";
#			} elsif ( $uname =~ m/Linux/) {
#				$nf = "-1";
#			}
#			return $nf;
#}
#
## Here comes mount manipulation ($NF) for each host
#sub OS_DF {
#	($cmd, $nf) = @_;
#	@df = system "$cmd";
#	foreach $mount (@df) {
#		chomp($mount);
#		next if /\bMounted on\b|proc|mnttab|swap|sado|dev\/fd/;
#		my(@line) = split(/ /, $mount);
#		$lines = ":$line[$nf]";
#	}
#	return $lines;
#}
unlink "$group.temp";
unlink "$group.tmp";	