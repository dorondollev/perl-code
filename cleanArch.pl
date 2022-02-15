#!/usr/bin/perl -w

$dir=("/oradata/soloprod/arch01");

if (&df("$dir") >= '80') {
	print "backup FS\n";
} else {
	print "every thing is OK\n";
}

$dateTime = &MMinfo($dir);
print $dateTime;

sub MMinfo {
	@dir = @_;
	@array = `mminfo -s atlas -q "name=@dir" -r 'savetime(17)'`;
	return "$array[-1]";
}

sub Save {
}

sub df {
	@dir = @_;
	open(DF, "/bin/df -h @dir|") or die "Can't execute: $!";
	while (<DF>) {
		next if $_ =~ /Filesystem/;
		@line = split(/\s+/, $_);
		(@percent) = split(/\b%/, $line[-2]);
		return $percent[0];
	}
}