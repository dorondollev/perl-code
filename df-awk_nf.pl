#!/usr/bin/perl
open(DF, "/bin/df|") or die "Can't $!";
while (<DF>) {
split;
print "$_[-1]\n";
}