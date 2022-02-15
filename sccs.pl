#!/usr/bin/perl -w

#-------PARAMETERS--------
use File::Copy;
use Getopt::Std;
getopts('s:t:gph');

#------ENVIRONMENT-------
$ENV{PATH} = "$ENV{PATH}:/usr/ccs/bin/";
$home = $ENV{'HOME'};
print "home<$home>\n";
$logname = $ENV{'LOGNAME'}; # username
print "logname<$logname>\n";
unless($opt_s)
{
    &help();
    exit 1;
}
$file = $opt_s;
print "file<$file>\n";
($name, $suffix) = split(/\./, $file);
$sFile = "s" . "." . $file;
print "sFile<$sFile>\n";
$pFile = "p" . "." . $file;
print "pFile<$pFile>\n";
$srcDir = &sourceDir($suffix);
$srcDirLocation = "$home\/dev\/SCCS\/$srcDir";
print "srcDirLocation<$srcDirLocation>\n";
#$status = &dirCheck($srcDirLocation);
#print "status<$status>\n";
$objExt = compiledFileExtension($suffix);
print "objExt<$objExt>\n";
$objDir = targetDir($suffix);
print "objDir<$objDir>\n";
$objFile = $name . "." . $objExt;
print "objFile<$objFile>\n";
if (($status = &fileCheck($srcDirLocation)) == 1)
{
	print "file check status<$status>\n";
	#if(($status=&sccsNew($file, $srcDirLocation)) == 0)
	if(($status=&sccsNew()) == 0)
	{
		print "Successfully created NEW SCCS file for $file\n";
	}
	print "sccsNew status <$status>\n";
}
if($opt_g)
{
    if (($status = get()) == 1)
	{
		print "ERROR: FAILED to get $sFile from $srcDirLocation\n";
	}
	else
	{
		print "File: $sFile successfully created\n";
	}
}
if($opt_p)
{	
    unless($opt_t)
    {
        print "Must enter target site <ntbg|main>\n";
        &help();
        exit 1;
    }
    $targetSite = $opt_t;
	print "targetSite<$targetSite>\n";
    &put($targetSite, $file);
}
if($opt_h)
{
    &help();
    exit 0;
}

#-----FUNCTIONS--------

sub get
{
	if (`get -e $srcDirLocation/$sFile`)
	{
		return 0;
	}
	return 1;
}

sub sccsNew
{
	#$file = shift;
	#$srcDirLocation = shift;
	# admin -i$f -r1 -n -y"$COMMENT" $sfldr/s.$f
	if (`admin -i$file -r1 $srcDirLocation/s.$file`)
	{}
	return $?;
}

sub fileCheck
{
	$dir = shift;
	if (-f "$dir\/$sFile")
	{
		return 0;
	}
	return 1;
}


sub dirCheck
{
	$dir = shift;
	print "dir<$dir>\n";
	chomp $dir;
    if (-d $dir)
	{
		print "dir<$dir>\n";
		unless (-r $dir)
		{
			print "$0: ERROR: You do not have read permission on the Target directory requested $dir.\n";
			exit 1;
		}
		unless (-w $dir)
		{
			print "$0: ERROR: You do not have write permission on the Target directory requested $dir.\n";
			exit 1;
		}
		unless (-x $dir)
		{
			print "$0: ERROR: You do not have execute permission on the Target directory requested $dir.\n";
			exit 1;
		}
		return 0;
	}
    else
	{
		print "$0: ERROR: Target directory requested $dir NOT FOUND.\n";
		exit 1;
	}
}

sub compiledFileExtension
{
    $suffix = shift;
    if ($suffix eq "fmb")
    {
        return "fmx";
    }
    elsif ($suffix eq "mmb")
    {
        return "mmx";
    }
    elsif ($suffix eq "pll")
    {
        return "plx";
    }
    elsif ($suffix eq "rdf")
    {
        return "rep";
    }
    elsif ($suffix eq "sqr")
    {
        return "sqt";
    }
    elsif ($suffix eq "c")
    {
        return "exe";
    }
    else
    {
        return $suffix;
    }
}

sub sourceDir
{
    $suffix = shift;
    if ($suffix eq "c")
    {
        return "C";
    }
    elsif ($suffix eq "doc" || $suffix eq "pdf")
    {
        return "doc";
    }
    elsif ($suffix eq "pl")
    {
        return "perl";
    }
    elsif ($suffix eq "jpg" || $suffix eq "gif")
    {
        return "pic";
    }
    elsif ($suffix eq "sh" || $suffix eq "csh" || $suffix eq "ksh" || $suffix eq "bash")
    {
        return "sh";
    }
    elsif ($suffix eq "sqr" || $suffix eq "inc")
    {
        return "sqr";
    }
    else
    {
        return $suffix;
    }
}

sub targetDir
{
    $suffix = shift;
    if ($suffix eq "pl")
    {
        return "perl";
    }
    if ($suffix eq "fmb" || $suffix eq "mmb" || $suffix eq "olb" || $suffix eq "pll" || $suffix eq "gif" || $suffix eq "jpg")
    {
        return "forms";
    }
    elsif ($suffix eq "rdf")
    {
        $dir = "reports";
        $ext = ".rep";
    }
    elsif ($suffix eq "sqr" || $suffix eq "sql" || $suffix eq "ctl" || $suffix eq "c" || $suffix eq "sh" || $suffix eq "csh")
    {
        return "bin";
    }
    elsif ($suffix eq "inc")
    {
        return "perm";
    }
    elsif ($suffix eq "doc" || $suffix eq "pdf")
    {
        return "xml";
    }
    elsif ($suffix eq "ksh" || $suffix eq "bash")
    {
        return "\/users/util";
    }
    else
    {
        return "other";
    }
}

sub help
{ #t:d:s:gph
    print "$0 ver 1.0 written by Doron Dollev Feb 1 2017\n\n";
    print "\t$0 <-s source_file> <-p|-g> [-d objDir][-t targetDir]\n\n";
    print "\t-s Must provide source file\n";
    print "\t-g Get last source file version\n";
    print "\t-p Publish file\n";
    print "\t-d Optional, provide unlisted object dir\n";
    print "\t-t Required if publishing, insert target site, <ntbg|main>\n";
    print "\t-h     Print this help screen.\n\n";
    print "\t       Example: ./accrm.pl -f webinv\n";
}