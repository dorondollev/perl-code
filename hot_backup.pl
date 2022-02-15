#!/usr/bin/perl -w

$ENV{"ORACLE_HOME"} = "/oracle/product/11.2.0/dbhome_1";
$ENV{"ORACLE_SID"} = "dev1";
$ENV{"SRCLOC"} = "/backup/sbin";
$ENV{"ORADATA"} = "/oradata/dev1/data01";
$ENV{"ARCHIVE"} = "/oradata/dev1/arch01";
$ENV{"REDO01"} = "/oradata/dev1/redo01";
$ENV{"REDO02"} = "/oradata/dev1/redo02";
$oracle_home = $ENV{"ORACLE_HOME"};
$srcloc = $ENV{"SRCLOC"};
print "$oracle_home\n";
print "$srcloc\n";
system("su - oracle -c $oracle_home/bin/sqlplus -s '/ as sysdba' \@$srcloc/BeginHotBackup.sql");