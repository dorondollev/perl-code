#!/usr/bin/perl -w

open(FILE, ">stam.log") or die "$!\n";
#select(FILE); $| =1; select(STDOUT);
select(STDOUT);
print "This line probably wont be written to disk now\n";
select(FILE);
print "This line will be written immediately. \n";
#select (STDOUT);
print "This line probably wont.";