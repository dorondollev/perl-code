#!/usr/bin/perl

use Cwd;
use Cwd 'chdir';
$dirname = "/wizard/oper7/work/yuval/post/bck";
chdir "$dirName";
system("find . \( -type d ! -name . -prune \) -o \( -name \"*.gz\" -ctime +30 \) -exec gzip {} \;");
system("find . \( -type d ! -name . -prune \) -o \( -name \"*.gz\" \) -exec mv {} oldfiles \;");
$dirname = "/wizard/oper7/work/yuval/post/tmp";
chdir "$dirName";
system("find . \( -type d ! -name . -prune \) -o \( -name \"*.dat\" -ctime +183 \) -exec rm -f {} \;");
$dirname = "/wizard/oper7/work/yuval/post/log";
chdir "$dirName";
system("find /wizard/oper7/work/yuval/post/tmp -ctime +183 -exec rm -f {} \;");
