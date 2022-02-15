#!/usr/bin/perl
$dir="./";
@files = glob "$dir/*";
foreach $file (@files) {
print $file, "\n";
}