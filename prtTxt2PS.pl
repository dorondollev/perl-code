#!/usr/bin/perl -w


@printers=openPrintersFile("printers.txt");
foreach (@printers)
{
	chomp;
	#$printer = showPrinterConf($_);
	#chomp($printer);
	#print "$printer\n";
	showPrinterConf($_);
}

sub showPrinterConf
{
	$printerAlias=shift;
	open(PRT, "/usr/bin/lpstat -l -p $printerAlias|") or warn "Couldnt find priter $printerAlias: $!\n";
	while(<PRT>) {
		if ($_ =~ /\bDescription:/) {
			$description = $_;
		}
		if ($_ =~ /\bdest/)
		{
			chomp();
			@line = split(/ /, $_);
			@line = sort(@line);
			@destPrinter = split /=/, $line[1];
			@printerPort = split /:/, $destPrinter[-1];
			$printer = $printerPort[0];
			chomp $printer;
			$result = `/usr/sbin/ping $printer`;
			$status = $?;
			if ($status ne '0') {
				print "Printer name: $printerAlias\n";
				print "Printer host: $printer\n";
				print "Description: $description\n";
				print "Ping result is: $result\n";
				print "------------------------------------------------------\n";
			}
			else {				
				# lpadmin -p prt_mkd_post -o protocol=bsd,dest=prtkirmkd -v /dev/null -m netstandard -T PS -I postscript
				# enable $PNAME
				# accept $PNAME
				# lpstat -p $PNAME -l|more
				# lpstat -a $PNAME
				$counted = wordCount($printerAlias);			
			}
		}
	}
}

sub wordCount
{
	$name = shift;
	$count = 0;
	@printerName = split(/\s*/, $name);
	for ($i=0;$i <= $#printerName;$i++) {
		$count++;
	}
	if ($count > 12) {
		print "Printer name: @printerName";
		print " count: $count\n";
		removeLastChar($count, @printerName);		
	}
}

sub removeLastChar
{
	$count = shift;
	@array = @_;
	print "Current printer name is:\t@array\n";
	for ($i=$count; $i <= 12; $i--) {
		print "current last char is: $array[$#array]\n";
		pop(@array);
		print "current last char is: $array[$#array]\n";
	}	
	print "New printer name is:\t@array\n";
}

sub openPrintersFile
{
	$PRINTERS=shift;
	open(PRINTERS);
	@printers=<PRINTERS>;
	close(PRINTERS);
	return @printers;
}
