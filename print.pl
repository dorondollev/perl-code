#!/usr/bin/perl -w
 
@printers=openPrintersFile("printers.txt");
foreach (@printers)
{
        chomp;
	$count = wordCount($_);
	while ($count > 12) {		
		print "$_\n";
		chop;
		print "$_\n";
		$count--
	}
	$current = $_."_p";
	print "$current\n";
}

sub wordCount
{
        $name = shift;
        $count = 0;
        @printerName = split(/\s*/, $name);
        for ($i=0;$i <= $#printerName;$i++) {
                $count++;
        }
	return $count;
        #if ($count > 12) {
        #       print "Printer name: @printerName";
        #       print " count: $count\n";
        #       removeLastChar($count, @printerName);
        #}
}

sub openPrintersFile
{
        $PRINTERS=shift;
        open(PRINTERS);
        @printers=<PRINTERS>;
        close(PRINTERS);
        return @printers;
}