#!/usr/bin/perl -w

use strict;
use DBI;
my($id, $value, $table) = @ARGV;
         my $dbh = DBI->connect("DBI:mysql:database=backup;host=localhost",
                                "doron", "margut#1",
                                {'RaiseError' => 1});
my $sth = $dbh->prepare("SELECT $id, $value FROM $table");
         $sth->execute();
         while (my $ref = $sth->fetchrow_hashref()) {
          print "$ref->{$id}\n", "$ref->{$value}\n";
         }
         $sth->finish();

$dbh->disconnect();