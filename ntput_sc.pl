#!/usr/bin/perl -w

use Getopt::Std;
getopts('pnyhf:');

$user = $ENV{'USER'};
$prdHost = "prdzone1";
$prdInstance = "prd1";
$ntPrdHost = "ntpzone1";
$ntHrmHost = "nthzone1";
$ntHrmInstance = "nthrm1";
$ntPrdInstance = "ntprd1";
$localHost = `hostname`;

%extension = (
			fmb => { forms => 'fmx' },
			pll => { forms => 'plx' },
			olb => { forms => 'olb' },
			mmb => { forms => 'mmx' },
			gif => { forms => 'gif' }, 
			jpg => { forms => 'jpg' },
			rdf => { reports => 'rdf' },
			sqr => { bin => 'sqt' }, 
			inc => { bin => 'inc' }, 
			sql => { bin => 'sql' }, 
			ctl => { bin => 'ctl' }, 
			sh  => { bin => 'sh'  }, 
			csh => { bin => 'csh' }, 
			c   => { bin => 'exe' },
			util=> { ksh => 'ksh' },
			);

if($user ne "sccs")
{
	print "run time user must be sccs";
	exit 2;
}

if ($opt_h)
{
	&help();
	exit 0;
}

unless ($opt_f)
{
	print "you must enter <-f object_file>\n";
	&help();
	exit 1;
}
$file = $opt_f

if ($opt_p) 
{
	# production connected via NAS NFS
	$host = $localHost;
	$targetDir = getTargetDir($host, $prdInstance); 
}
elsif ($opt_n)
{
	# NTBG production connected via NAS NFS
	$host = $localHost;
	$targetDir = getTargetDir($host, $ntPrdInstance); 
}
elsif ($opt_y)
{
	# NTBG Nayedet is stand alone there for connected via ssh|scp
	$host = $ntHrmHost;
	$targetDir = getTargetDir($host, $ntHrmInstance); 
}
else
{
	print "you must enter [-p|y|n] for host target\n";
	&help();
	exit 1;
}






=========== functions =======================



sub link
{
	$file = shift;
	$dir = shift;
}

sub getTargetDir
{
	$host = shift;
	$instance = shift;
	$dir = "/$host/app/$instance";
	$localHost = `hostname`;
	if ($host ne $localHost)
	{
		$status = hostAlive($host);
		if($status != 0)
		{
			print "NO REPLY FROM $host. Program can't continue!\n";
			exit 2;
		}
		`su - $user -c "ssh $host \"ls -l $dir\""`;
		if($? != 0)
		{
			print "Can't access to $host $dir exiting...\n";
			exit 2;
		}
	}
	else
	{
		dirCheck($dir);
	}
	return $dir;
}

sub move
{
	$host = shift;
	$file = shift;

	($prefix, $postfix) = split(/./, $file);
	if($host eq $ntHrmHost)
	{
		if($postfix eq "plx")
		{
			print "$file needed for Tashlumat on $ntPrdHost ONLY.\n";
			print "Therefore it will not be copied to $ntHrmHost\n";
			exit 2;
		}
	}
}

sub hostAlive
{
	$host = shift;
	`ping -t1 $host`;
	return $?;
}

sub dirCheck
{
	$dir = shift;
	unless (-d $dir)
	{
		print "$0 ERROR: directory $dir NOT FOUND\n";
		exit 2;
	}
	return 0;
}

sub help
{
	print "\tUSAGE: $0 [-pny] [-h] <-f object_file>\n";
	print "\t-p:\trepresnts production host.\n";
	print "\t-n:\trepresnts ntbg production host.\n";
	print "\t-y:\trepresnts nayedet host.\n";
	print "\t-f file: object file, required parameter.\n";
	print "\t-h:\tthis help.\n";
====================== OLD ========================================================
	#print "$0: ERROR CALL. USAGE: $0 file [ ... ]  [ target_dir ]\n";
	#print "\tfile - file to be compiled and copied to working directory\n";
	#print "\t\t- it must be in $NTPREPROD\n\t\tor in $NTPREPROD/scripts\n";
	#print "\t\t[ ... ] - optional extra file names.\n";
	#print "\t\t[ target_dir ] - optional target directory if not the usual one\n";
	return 0;
}