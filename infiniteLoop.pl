#!/usr/bin/perl -w

&infiniteLoop();

sub infiniteLoop {
        $| = 1;
        @signs = ('|', '/', '-', '\\', '|', '/', '-', '\\', '|');
        $j = 1;
        $i = 0;
        while (1) {
			print "$signs[$i]\r\t";
			print "$j\r";
            sleep 1;
            $i = '0' if $i == $#signs;
            $i++;
            $j++;
		}
}