#!/usr/bin/perl


### The uncommented lines will wait until the commented lines which belongs to another script
### shall release the locking from the file.

use Fcntl 'LOCK_EX', 'LOCK_UN';

        open(LOCK, ">>/app/oracle/product/cron/stam.lck");
        flock(LOCK, LOCK_EX);
        print LOCK $$;
		flock(LOCK, LOCK_UN);


### This lines belong to a 2nd script which locks a file for 40 seconds
#	open(LOCK, ">>/app/oracle/product/cron/stam.lck");
#	for ($i=3;$i>0;$i--) {
#		if (!flock(LOCK, LOCK_EX | LOCK_NB)) {
#			warn "There´s another server running! \n";
#			sleep 10;
#		}
#	}
#	print LOCK $$;
#}
