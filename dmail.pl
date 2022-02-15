#!/usr/bin/perl -w

use strict;
use Getopt::Std;
use Mail::Sendmail 0.75;
use MIME::QuotedPrint;
use MIME::Base64;

getopts('hdos:g:r:a:b:c:f:m:w:M:');
my %mail = (
         from => 'doron@ashrait.dbs.co.il',
         to => 'doron.dollev@dbs.co.il',
         subject => 'Test attachment',
        );
my $message = encode_qp( "sending stam.txt`." );
my $file = "stam.txt";
open (OUTFILE, "$file") or die "Cannot read $file: $!";
binmode OUTFILE; undef $/;
$mail{body} = encode_base64(<OUTFILE>);
close OUTFILE;
my $boundary = "====" . time() . "====";
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

sub usage {
    print <<ENDOFUSAGE;
        maild.pl [-u] [-h] [-f from] [-m mailhost] [-p port]
		[-s subject] [-c cc-addr] [-b bcc-addr] [-r replyto-addr]
		[-a attachment#1[:attachment#2...]] [-w] to_addresses
	-a		List of files to attach, colon seperated
	-b		List of blind carbon copy addresses
	-c		List of carbon copy addresses
	-f		Email sender's address (FROM:)
	-M		Shows the man page (help)
	-m		SMTP mailhost (name or IP address)
	-w		Do not wait on STDIN for message part
    -o		Override headers
	-p		Port to use when connecting to mailhost
	-r		Email reply-to address
	-s		Subject to use
	-h		Shows this usage information
	to_addresses    Email recipients address (TO:) in a comma
                  seperated list

ENDOFUSAGE

  exit(0);

} # End sub usage

sub manpage {
    my($pager) = 'more';
    $pager = $ENV{'PAGER'} if $ENV{'PAGER'};
    if ( $ENV{'TERM'} =~ /^(dumb|emacs)$/ ) {
    system ("pod2text $0");
    } else {
    system ("pod2man $0 | nroff -man | $pager");
    }
    exit (0);
}
__END__

=head1 NAME

mail.pl - Send SMTP/MIME email

=head1 SYNOPSIS

B<mail.pl> [B<-a file1[:file2...]>]
        [B<-b bcc list>]
        [B<-c cc list>]
        [B<-f sender>]
        [B<-h>]
        [B<-m mailhost>]
        [B<-o>]
        [B<-w>]
        [B<-p mail port>]
        [B<-r replyto>]
        [B<-s subject>]
        [B<-u>]
        to_addresses
 

=head1 DESCRIPTION

I<mail.pl> allows a user to send SMTP/MIME compliant email 
to a specified list of email addresses.

I<mail.pl> is intended to be a nearly-complete drop-in 
replacement for Unix's /bin/mail, when used to send mail.
This script provides similar command-line arguments but
is extended to enable the sending of MIME-compliant mail
and reduces the need for a local MTA.

Mail is sent via an SMTP-compliant network connection to
a mail transfer agent, possibly on a different machine.

This script will wait on STDIN (as does /bin/mail) for
some text to be used as the first (textual) message body
part.  Unlike /bin/mail, this behavior may be overriden
by use of switch w.  Failure to provide a Subject: on 
the command line does NOT result in the user being asked
for one (this also differs from /bin/mail).

=head1 OPTIONS

=over 6

=item B<-u> (usage)

Display the usage statement.

=item B<-h> (help)

Display the man page.

=item B<-f sender> (Sender's email address)

Provide an email address for the person sending the message.

=item B<-r replyto> (Replyto email address)

Provide a replyto email address for the message.

=item B<-m mailhost> (Mailhost)

Provide the name of the SMTP mailhost used to route SMTP mail.

=item B<-o> (Header Override)

If this flag is set, the message provided must contain additional
headers followed by a blank line and a message body.  It can be
used to write additional headers into a message.  If you use this
option, you must provide the blank line separarting headers and body!

=item B<-w> (No STDIN)

If this flag is given, do not wait on STDIN for the first
(textual) message body part.  The default is that this 
script will wait for input via STDIN for some text to be 
entered.  The text entry is terminated by a Ctrl-D 
interruption or by entering a '.' on a line by itself.  
This flag overrides the default behavior.

=item B<-p mail port> (Mailhost port)

Provide a port number to use when sending mail to the mailhost specified.  The default port is 25, a well-known port used for SMTP mail transfers.

=item B<-s subject> (Subject)

Provide the subject for the mail.

=item B<-a attachment list> (Attachment list)

List of files to be MIME encoded, and attached.  This list is colon-separated if more than one file to attach is given.  For example:

     -a "file1.txt:file2.html:file3.gif:file4.ps"

would attach four files, but

     -a file1.txt

would only attach one file.

=item B<-c cc list> (CC List)

Provides a list of addresses to cc the message to.

=item B<-b bcc list> (BCC List)

Provides a list of addresses to bcc the message to.

=item to_addresses (Recipients' email addresses)

A comma-separated list of email addresses for the recipient of the message.  Each address must include an '@' sign.

=back

=head1 AUTHOR

Doron Dollev <C<doron.dollev@gmail.com>>

=head1 LIMITATIONS

This script is intended to be a drop-in replacement for the UNIX /bin/mail program for sending mail, with enhancements to allow MIME compliance.  However, no attempt has been made to duplicate or replace /bin/mail's e-mail reading and manipulation capabilities.

=cut