#!/usr/bin/perl

$rcpt = shift;

open (BODY, "|/usr/lib/sendmail $rcpt");
while (<>) {
   if (/^NetWorker savegroup/) {
      print BODY "Subject: $_";
(@subject) = split(/,/, $_);
   }
   print BODY $_;
}
close(BODY);
(@first) = split(/\s+/, $subject[0]);
#system "/nsr/opt/sado/nsrqry.pl $first[-2]";