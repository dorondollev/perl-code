#!/usr/bin/perl -w

$ip = '10.1.14.50';
$descriptor = "ibmsnew";
@getlun = `navicli -h $ip getlun -name -owner | /bin/egrep '$descriptor|A|B' | awk '{print \$NF}'` or die "$!\n";
for ($i=0;$i<=$#getlun;$i++) {
	if ($getlun[$i] =~ /$descriptor/) {
		$a = ($i + 1);
		$found .= $getlun[$i] . $getlun[$a];
	}
}
print $found;