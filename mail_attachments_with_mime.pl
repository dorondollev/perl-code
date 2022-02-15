#!/usr/bin/perl -w

use MIME::Lite;
@attach = `find . -name "stam*"`;
$to = 'dorond@moia.gov.il';
if ($attach[0])
{
        $body_msg = "Message body ... Attachments included\n\n";
        $msg = MIME::Lite->new(To => $to, Subject => 'test message', Type => 'multipart/mixed');
        $msg->attach(Type => 'TEXT', Data => $body_msg);
        for ($i=0; $i <= $#attach; $i++)
        {
                chomp $attach[$i];
                $msg->attach(Type => 'multipart/mixed', Path => $attach[$i],
                        Filename => $attach[$i], Disposition => 'attachment');
        }
        $msg->send();
}
else
{
        print "array is empty\n";
}