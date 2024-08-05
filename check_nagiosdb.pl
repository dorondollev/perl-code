#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Std;
use DBI;

# MySQL database configuration
my $database = 'nagiosdb';
my $hostname = 'localhost';
my $username = 'nagios';
my $password = 'manager11';
my $warn_time = 600;
my $crit_time = 1200;

# Connect to the database
my $dsn = "DBI:mysql:database=$database;host=$hostname";
my $dbh = DBI->connect($dsn, $username, $password, { RaiseError => 1, AutoCommit => 1 });

# Parse command-line options
my %options;
getopt('ciH', \%options);

# Extract command and input from options
my $command_name = $options{'c'};
my $host_name = $options{'H'};
my $query;
if ($options{'i'})
{
# Query the commands and status tables with command input
  my $command_input = $options{'i'};
  $query = "
        SELECT s.*, h.host_name
        FROM commands c
        JOIN status s ON c.commands_id = s.commands_id
        JOIN hosts h ON c.hosts_id = h.hosts_id
        WHERE c.command_name = $command_name
        AND h.host_name = $host_name
        AND s.status_line LIKE '%$command_input%'
        ORDER BY s.status_date DESC
        LIMIT 1
    ";
}
else
{
# Query the commands and status tables
  $query = "
    SELECT s.*, h.host_name
    FROM commands c
    JOIN status s ON c.commands_id = s.commands_id
        JOIN hosts h ON c.hosts_id = h.hosts_id
    WHERE c.command_name = $command_name
        AND h.host_name = $host_name
    ORDER BY s.status_date DESC
    LIMIT 1
    ";
}

# Prepare and execute the query with command_name as a parameter
my $sth = $dbh->prepare($query);
$sth->execute($command_name);
my $curdate = `date +%s`;
# Check if the query returned any rows
if (my $row = $sth->fetchrow_hashref()) {
    my $status_line = $row->{'status_line'};
        my $status_date = $row->{'status_date'};
    my $exit_status = $row->{'status_exit'};
        if ($curdate - $status_date > $warn_time)
        {
                print "WARNING - last check time exceeded $warn_time";
                exit 1;
        }
        if ($curdate - $status_date > $crit_time)
        {
                print "CRITICAL - last check time exceeded $crit_time";
                exit 2;
        }
    # Split the status_line to get the relevant status information
    my ($status) = ($status_line =~ /^([^\[\]]+)/);

    # Print the status and exit status
    print "Status: $status\n";

    # Determine the appropriate exit code based on the status
    my $exit_code;
    if ($exit_status eq 'OK') {
        $exit_code = 0;
    } elsif ($exit_status eq 'WARNING') {
        $exit_code = 1;
    } elsif ($exit_status eq 'CRITICAL') {
        $exit_code = 2;
    } else {
        $exit_code = 3; # Custom exit code for other/unexpected statuses
    }

    # Exit the script with the determined exit code
    exit $exit_code;
} else {
    print "No status information found for command: $command_name\n";
    exit 3; # Exit with UNKNOWN (3) status as no status information is available
}

# Disconnect from the database
