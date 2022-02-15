#!/usr/bin/perl -wl

use Getopt::Std;
getopts('ti:N:');

if ($opt_i) {
	print " Input: $opt_i";
}
if ($opt_N) {
	print " Name: $opt_N";
}
if ($opt_t) {
	print " Toggle: $opt_t";
}