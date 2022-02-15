#!/usr/bin/perl
$host = shift;
@lines = `rsh $host \"/bin/df\"`;
if(@lines) {
        foreach (@lines) {
        next if /\bMounted on\b/;
        (@line) = split(/ /, $_);
            print "$line[-1]";
        }
    }