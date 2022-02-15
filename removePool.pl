#!/usr/bin/perl -w

%poolList=(
"Olympus DWH Clone1y",0,
"Olympus DWH Clone7y",0,
"Olympus Monthly DWH",0,
"Olympus DWH Clone2m",0,
"Olympus Weekly DWH",0,
"Olympus Weekly",0,
"Olympus Monthly",0,
"Olympus Clone2m",0,
"Olympus Clone1y",0,
"Olympus Clone7y",0,
"Olympus Yearly",0,
"Olympus Yearly DWH",0,
"Atlantis Monthly",0,
"Atlantis Weekly",0,
"Atlantis Daily",0,
"Atlantis Yearly",0,
"Atlantis Clone1y",0,
"Atlantis Clone2m",0,
"Atlantis Clone2w",0,
"Atlantis Clone7y",0,
"Clone1y",0,
"Clone2m",0,
"Clone7y",0,
"Work Daily",0,
"Work Monthly",0,
"Work Weekly",0,
"work Eternity",0,
"Work Yearly",0,
"Clone2m",0,
);

foreach $pool (keys(%poolList)) {
        print "P o o l: $pool\n";
        $msg .= "P o o l: $pool\n";
        print "================================\n";
        $msg .= "==============================\n";
        open(MM, "mminfo -s atlas -q 'pool=$pool' -r volume,state 2>/dev/null|") or die "$!\n";
        while(<MM>) {
                chomp;
                next if $_ =~ /volume/;
                if ($_ =~ /U0|X/) {
                        print "$_\n";
                        $msg .= "$_\n";
                        if ($_ =~ /E/) {
                                $poolList{$pool} = 1;
                        }
                        else {
                                $poolList{$pool} = 2;
                        }
                }
        }
        close MM;
        print "P o o l  $pool  S u m m a r y\n\r";
        print "================================\n";
        if ($poolList{$pool} == 0) {
                print "Pool $pool may be removed from poolList\n";
                $msg .= "Pool $pool may be removed from poolList\n";
        }
        elsif ($poolList{$pool} == 1) {
                print "Pool $pool may be removed from poolList, but need to delete all eraseable volumes first\n";
                $msg .= "Pool $pool may be removed from poolList, but need to delete all eraseable volumes first\n";
        }
        elsif ($poolList{$pool} == 2) {
                print "Pool $pool is active\n";
                $msg .= "Pool $pool is active\n";
        }
        print "\n\n\n";
        $msg .= "\n\n\n";
}

if ($msg) {
        &MailError($msg);
} else {
        exit 0;
}

sub MailError {
        my $message = shift;
        my $sendmail = "/usr/lib/sendmail -t";
        my $subject  = "Check for unused Networker pools";
        my @rcpts = qw(doron.dollev@dbs.co.il ori.michaeli@dbs.co.il);
                for ($i=0;$i<=$#rcpts;$i++) {
                        open (SENDMAIL, "|$sendmail");
                        print SENDMAIL "Subject: $subject\n";
                        print SENDMAIL "From: doron\@atlantis.dbs.co.il\n";
                        print SENDMAIL "To: $rcpts[$i]\n\n";
                        print SENDMAIL "$message\n";
                        close(SENDMAIL);
                }
}