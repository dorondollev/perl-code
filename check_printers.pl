#!/usr/bin/perl

use strict;
use warnings;

# Initialize error variable
my $error = 0;

# Declare @output array outside the loop
my @output;

# Run lpstat -a command
my @lpstat_output = `lpstat -a`;

# Process lpstat -a output
foreach my $line (@lpstat_output) {
    chomp $line;
    my ($printer_name, $status) = split /\s+/, $line;

    # Check if printer is not accepting jobs
    if ($status ne 'accepting') {
        $error++;

        # Add errored line to @output array
        push @output, $line;
    }

    # Run lpstat -p <printer_name> -l
    my @lpstat_p_output = `lpstat -p $printer_name -l`;

    # Check if the printer is enabled
    if (!grep { /printer $printer_name is idle.  enabled/ } @lpstat_p_output) {
        $error++;

        # Add errored line to @output array
        push @output, @lpstat_p_output;
    }
}

# Display results
if ($error == 0) {
    print "OK - All printers are accepting jobs and enabled.\n";
    exit 0;
} else {
    print "WARNING - Number of errors found: $error\n";
    print join("\n", @output), "\n";
    exit 1;
}
