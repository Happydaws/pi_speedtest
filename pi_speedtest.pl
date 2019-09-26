#!/usr/bin/perl



############################ Setting Variables ############################
use strict;
use warnings;
use DateTime;
use DBI;
my ($ping, $download, $upload, $share);

############################ Setting Date / Time ############################
my $dt = DateTime->now;
my $dato = $dt->dmy;
my $tid = $dt->hms;

############################ Preparing Database ############################
my $dsn = "dbi:SQLite:dbname=/home/klh/Documents/Projects/pi_speedtest/pi_speedtest.sqlite";
my $dbh = DBI->connect($dsn, , , {AutoCommit => 1}) or die "Cannot connect to DB";
my $sth = $dbh->prepare("INSERT INTO speedtest VALUES (?, ?, ?, ?, ?, ?, ?)");



############################ Speedtesting ############################
my $speedtest = `/usr/bin/speedtest-cli --share`;

print $speedtest;

if ($speedtest =~ s/:\s(\d+\.\d+)\sms//) { 	$ping = $1; }
if ($speedtest =~ s/Download:\s(.*)\n//) { 	$download = $1; }
if ($speedtest =~ s/Upload:\s(.*)\n//) { 	$upload = $1; }
if ($speedtest =~ s/result\/(\d+)\.png//) { 	$share = $1; }

$sth->execute($dato, $tid, $ping, $download, $upload, $share, "OK");



print "\nDato: $dato \t Tid: $tid \t Ping: $ping \t Download: $download \t Upload: $upload \t Share: $share\n";


$dbh->disconnect;

