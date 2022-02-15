#!/usr/bin/perl -w

chdir "/prdzone1/app/share/prd1/inout/month_out";
@attach = `/opt/sfw/bin/gfind . -type f -mmin -60 -name "*mts*"`;
if ($attach[0])
{
        for ($i=0; $i <= $#attach; $i++)
        {
                chomp $attach[$i];
                `uuencode $attach[$i] $attach[$i] >>/tmp/mail.out`;
        }
        $status = `mailx -s "month_out klt mts attachments" dafnal\@moia.gov.il </tmp/mail.out`;
        $status = `mailx -s "month_out klt mts attachments" dorond\@moia.gov.il </tmp/mail.out`;
        unlink("/tmp/mail.out");
}
else
{
        $status = `mailx -s "no new files found in last 60 minutes" dorond\@moia.gov.il`;
}