#!/usr/bin/perl

use Net::Telnet ();

$host = shift;
$command = shift;
&net_telnet($host, $command);

sub net_telnet {
$username = sado;
$passwd = SadoMazo;
    $t = new Net::Telnet (Timeout => 10,
                          Prompt => '/\$/');
    $t->open("$host");
    $t->login($username, $passwd);
    @lines = $t->cmd("$command");
    print @lines;
}