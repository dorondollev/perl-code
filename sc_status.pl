#!/usr/bin/perl -wl

$ip = '10.1.14.50';

@volume =  ("ibmsnew-vol4", "ibmsnew-vol3", "ibmsnew-vol2", "ibmsnew-vol1");
#while (@volume) {
	for ($i=0;$i<=$#volume;$i++) {
#		chomp $volume[$i];
		$status = &GetSCstatus($volume[$i], $ip);
		print $status;
		@stat = split(/ /, $status);
		shift(@stat);
		print "$volume[$i]";
			for ($i=0;$i<=$#stat;$i++) {
				print "$stat[$i]";
			}
	#	if ($stat[0] !~ /complete/) {
#		print "$volume[$i] is in $stat[1]%";
#	} elsif ($stat[0] =~ /complete/) {
#		if ($stat[2] =~ /NoFailure/) {
#			print "$volume[$i] completed";
#			delete $volume[$i];
#		}
#	}
	}



sub GetSCstatus {
	($vol, $ip) = @_;
	my $r;
	undef $r;
#	print $vol;
	open(STAT, "navicli -h $ip sancopy -info -name $vol -complete -sessionstatus -failure|") or die "$!";
	while (<STAT>) {
		chomp;
		s/\s*//g;
		(@line) = split(/:/, $_);
		print $line[1];
		$r .= " $line[1]";
	}
	return $r
}
	

# $var = &GetCompName;
# @complete = split(/ /, $var);
# shift @complete;
# while (@volume) {

#sub GetCompName {
#	for ($i=0;$i<=$#volume;$i++) {
#		$comp .= " complete$i";
#	}
#	return $comp;
#}
#@status = `navicli -h $ip sancopy -info -name ibmsnew-vol3`;
# delete $array[index]