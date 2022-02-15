#!/usr/bin/perl -w
unless (open(INFILE, "./dump")) {
die ("$!\n");
}
unless (open(OUTFILE, ">dump.html")) {
die ("cannot open output file dump.html\n");
}
$line = <INFILE>;
print OUTFILE ('<html>');
open (OUTFILE, ">>dump.html");
print OUTFILE ('<body>');
print OUTFILE ('<p align=right>');
while ($line ne "") {
print OUTFILE ($line, '<br>');
$line = <INFILE>;
}
print OUTFILE ('</p>');
print OUTFILE ('</body>');
print OUTFILE ('</html>');

use MIME::QuotedPrint;
use MIME::Base64;
use Mail::Sendmail 0.75;

%mail = (
         from => 'doron@ashrait.dbs.co.il',
         to => 'doron.dollev@dbs.co.il',
         subject => 'Test attachment',
        );


$boundary = "====" . time() . "====";
$mail{'content-type'} = "multipart/mixed; boundary=\"$boundary\"";

$message = encode_qp( "sending dump.html." );

#Content-Type: text/plain; charset="iso-8859-8"
#$file = $^X; # This is the perl executable
#unless (open(F, "$file")) {
#die ("$!\n");
#}

$file = "dump.html";
open (OUTFILE, "$file") or die "Cannot read $file: $!";
binmode OUTFILE; undef $/;
$mail{body} = encode_base64(<OUTFILE>);
close OUTFILE;

$boundary = '--'.$boundary;
$mail{body} = <<END_OF_BODY;
$boundary

Content-Type: text/html; charset="windows-1255"
Content-Transfer-Encoding: quoted-printable

$message
$boundary
Content-Type: application/octet-stream; name="$file"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="$file"

$mail{body}
$boundary--
END_OF_BODY

sendmail(%mail, Smtp =>'cerberus.dbs.co.il') || sendmail(%mail, Smtp =>'mailsrv03.dbs.co.il') || print "Error: $Mail::Sendmail::error\n";