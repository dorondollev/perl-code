#!/usr/bin/perl -w

#########################################################################################################################
#                                                                                                                       #
#       the script uses "recycle.cfg" file that configures pool followed by retention time in days                      #
#       the calculation is made on the number of days required in each pool compared to the current ssid definition     #
#       the only reason not to use Networkers own retention is avoiding usage of too many client per backup group       #
#                                                                                                                       #
#########################################################################################################################

use Date::Calc qw(Delta_Days Add_Delta_Days);
#($today, $thisMonth, $thisYear) = (localtime)[3, 4, 5];
%pools = &getPools("myrecycle.cfg");
foreach $pool (keys(%pools)) {
        $offset = $pools{$pool};
        chomp $pool;
		print "pool is: $pool\n";
#        @ssid = &getSsid($pool);
#       foreach (@ssid) {
#                chomp;
#                ($y1, $m1, $d1) = getDate($_, 'savetime');
#                ($y2, $m2, $d2) = getDate($_, 'ssretent');
#                chomp($y1, $m1, $d1, $y2, $m2, $d2);
#                $delta = Delta_Days($y1, $m1, $d1, $y2, $m2, $d2);
#                ($year, $month, $day) = Add_Delta_Days($y1, $m1, $d1, $offset);
#                if ($delta > $offset) {
#                        print "ssid: $_, ssretent:$m2-$d2-$y2, savetime: $m1-$d1-$y1, delta: $delta, shouldbe: $month-$day-$year\n";
### The only thing the script does is the following line: change retention and browse policy of the alleged ssid ###
#                        system("/usr/sbin/nsrmm -S $ssid -w $month/$day/$year -e $month/$day/$year");
#                        system("/usr/sbin/mminfo -q \"ssid=$ssid\" -r \"savetime,ssretent,ssbrowse,state,pool\"");
#                }
#        }
}

sub getDate {
        $ssid = $_[0];
        $infoType = $_[1];
        $date = `/usr/sbin/mminfo -q \"ssid=$ssid\" -r $infoType | /bin/grep -v $infoType`;
        return &splitDays($date);
}

sub splitDays {
        $infoType = shift;
        ($m, $d, $y)=split(/\//, $infoType);
        return($y, $m, $d);
}

sub getSsid {
        $pool = shift;
        return `/usr/sbin/mminfo -q \"pool=$pool\" -r ssid | /bin/grep -v ssid`;
}

sub getPools {
        $POOLS=shift;
        open(POOLS);
        %pools=<POOLS>;
        close(POOLS);
        return %pools;
}