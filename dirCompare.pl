#!/usr/bin/perl -w
$ENV{'PATH'}='/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin';

$sourceDir = "/backup/db880/dbdocs";
$targetDir = "/mnt/prod";
opendir(TRGT, $targetDir) or die "Can't open dir $targetDir: $!\n";
close(TRGT);
opendir(SRC, $sourceDir) or die "Can't open dir $sourceDir: $!\n";
@sourceFiles = readdir(SRC);
closedir(SRC);
chdir $targetDir;
foreach $file (@sourceFiles)
{
        if(!-e $file)
        {
                print "missing file in $targetDir: $file\n";
        }
}

"C:\Program Files (x86)\Xming\Xming.exe" :0 -clipboard -multiwindow -dpi 108