#!/usr/bin/perl -w

open TSV, "maof.txt" or die $!;
$i=0;
$sma = 13;
while(<TSV>)
{
	($end, $start, $high, $low) = split();
	$endDay[$i++] = $end;
}
close(TSV);
for ($i=0,$j=$sma-1;$j <= $#endDay;$i++,$j++) 
{
	#$sum = getSum($i, $j, @endDay);
	print "i: $i j: $j\n";
}

sub getSum
{
	$firstElement = shift;
	$lastElement = shift;
	@myArray = @_;
#	print "firstElement: $firstElement lastElement: $lastElement\n";
	for ($i=$firstElement;$i < $lastElement;$i++) {
		$sum += $myArray[$i];
	}
	return $sum;
}




