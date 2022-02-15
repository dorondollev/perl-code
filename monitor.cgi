#!/usr/bin/perl -w
$ENV{'PATH'}='/bin:/sbin:/usr/bin:/usr/sbin:/usr/lib/nagios/plugins:/usr/local/bin';

$statUp = 'up';
$statDown = 'down';
$iconsDir = "../icons/monitor/";
#@symmetrix = {'979', '098'};
@hosts = ( ['unix', 'hercules1', 'hercules2', 'titan1', 'titan2', 'hercules', 'apollo', 'lotus'],
                ['windows', 'tsdrp01', 'tsdrp02', 'tsdrp03', 'tsdrp04', 'solodrp01', 'dc1drp', 'rasdrp01', 'emcsrv02'],
                ['mcdata', 'kf-mcdata', 'drp-mcdata'],
                ['cisco', 'kf-cisco', 'drp-cisco', 'drp-server-sw'] );

my @errors;
my @operates;

for ($i=0;$i<=$#hosts;$i++) {
        for ($j=0;$j<=$#{$hosts[$i]};$j++) {
                if ($j == 0) {
                        $type = $hosts[$i][$j];
                        $j++;
                }
                if (($type =~ /\bunix\b/) && (chkHost($hosts[$i][$j], 23) > 0) || (pingHost($hosts[$i][$j]) > 0)) {
                        print "$hosts[$i][$j] <img src=$iconsDir$type$statDown.jpg>";
                } elsif ($type =~ /\bunix\b/) {
                        print "$hosts[$i][$j] <img src=$iconsDir$type$statUp.jpg>";
                }
                if (($type =~ /\bwindows\b/) && (chkHost($hosts[$i][$j], 3389) > 0) || (pingHost($hosts[$i][$j]) > 0)) {
                        print "$hosts[$i][$j] <img src=$iconsDir$type$statDown.jpg>";
                } elsif ($type =~ /\bwindows\b/) {
                        print "$hosts[$i][$j] <img src=$iconsDir$type$statUp.jpg>";
                }
                if (($type =~ /\bmcdata\b/) || ($type =~ /\bcisco\b/) && (pingHost($hosts[$i][$j]) > 0)) {
                        print "$hosts[$i][$j] <img src=$iconsDir$type$statDown.jpg>";
                } elsif (($type =~ /\bmcdata\b/) || ($type =~ /\bcisco\b/)) {
                        print "$hosts[$i][$j] <img src=$iconsDir$type$statUp.jpg>";
                }
        print "<br>";
        }
}

sub chkHost {
        ($host, $port) = @_;
        system("check_tcp -p $port -H $host >/dev/null");
	    return $?;
}

sub pingHost {
        $host = shift;
        system ("check_icmp -H $host >/dev/null");
        return $?;
}
print "Content-type: text/html\n\n";

print <<"EOF";
<HTML>
<HEAD>
<TITLE>Monitor DRP</TITLE>
</HEAD>
<BODY>
EOF

print <<"EOF";
</BODY>
</HTML>
EOF