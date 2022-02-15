#!/usr/bin/perl

         use strict;
         use DBI();

         # Connect to the database.
         my $dbh = DBI->connect("DBI:mysql:database=backup;host=localhost",
                                "doron", "margut#1",
                                {'RaiseError' => 1});
my $sth = $dbh->prepare("SELECT distinct pool FROM bacstat");
$sth->execute();
while (my $ref = $sth->fetchrow_hashref()) {
$dbh->do("INSERT INTO pools VALUES (?, ?, ?)", undef, undef, "$ref->{'pool'}", undef);
print "$ref->{'pool'}\n";
}
$dbh->disconnect();