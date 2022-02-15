#!/usr/bin/perl

print "Content-type: text/plain", "\n\n";
print '<meta http-equiv="pragma" content="no-cache">';
#print '<meta http-equiv="Refresh" content="15">';
print '<Title> Predict Returned Volumes </title>';
print '<BODY bgcolor="#fbe995">';
print '<br>';
print '</font>';
print '<table>';
print '<tr>';
print '<td width="12%">';
print '&nbsp;';
print '</td>';
print '<td>';
print '<h2><font color="navy">';
print 'Predict returned volumes';
print '</font>';
print '</h2>';
print '<a href="http://atlas.dbs.co.il/predict.html" alt="Back to predict menu" target="_top">';
print 'Back to predict menu';
print '</a>';
print '<HR>';
print '<table align="center" border="1" cellpadding="6" cellspacing="2" bgcolor="#fef7d4">';
print '<tr>';
print '<th>';
print "No.";
print '</th>';
print '<th>';
print "Volume <BR> Retention";
print '</th>';
print '<th>';
print "Pool";
print '</th>';
print '<th>';
print "Volume";
print '</th>';
print '<th>';
print "Location";
print '</th>';
print '</tr>';
$query_string = $ENV{'QUERY_STRING'};
($field_name, $command) = split (/=/, $query_string);
if ($command eq "0"||"1"||"2"||"3"||"4"||"5"||"6"||"7") {
$no = 1;
open(MM, "/usr/opt/networker/bin/mminfo -q 'volretent < \"+$command days\"' -o t -r volretent,space,pool,space,volume,space,location| /bin/sort|");
while (<MM>) {
next if /\bmanual\b/;
next if /\bvolume\b/;
#/([0-9][0-9]\/[0-9][0-9]\/[0-9][0-9]|\bexpired\b|\bundef\b)\s*(\w+\s*\w*\s*\w*)\s*([UN][XT]\d{6})\s*(\bjbux\b|s*)/;
/([0-9][0-9]\/[0-9][0-9]\/[0-9][0-9]|\bexpired\b|\bundef\b)\s*(\w+\s*\w*\s*\w*)\s*([UW]\d{5}[L][2]|[UN][XT]\d{6})\s*(\bjbux\b|s*)/;
$volretent = $1;
$barcode = $3;
$pool = $2;
$location= $4;
print "<tr><td> $no </td><td> $volretent </td><td> $pool </td><td> $barcode </td><td> $location </td> </tr>";
++$no;
}
}
print '</table>';
print '<td width="12%">';
print '&nbsp;';
print '</td>';
print '</tr>';
print '</table>';
print '</body>';