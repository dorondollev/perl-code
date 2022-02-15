#!/usr/bin/perl
use strict;
use vars qw($ENV $mminfo $hosts $group);
$ENV{'PATH'}='/bin:/sbin:/usr/bin:/usr/sbin:/usr/opt/networker/bin:/usr/local/bin';
$group = shift;
$mminfo = `mminfo -q "group=$group" -r pool`;
print "$mminfo";