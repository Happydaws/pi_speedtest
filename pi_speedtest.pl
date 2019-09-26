#!/usr/bin/perl



############################ Setting Variables ############################
use strict;
use warnings;
use DateTime;
use DBI;
my ($ping, $download, $upload, $share);



############################ Setting Date / Time ############################
my $dt = DateTime->now;
$dt->set_time_zone( 'Europe/Copenhagen' );
my $dato = $dt->dmy;
my $tid = $dt->hms;



############################ Setting Date / Time ############################
sub UpdateDB {
	my $dsn = "dbi:SQLite:dbname=/home/klh/Documents/Projects/pi_speedtest/pi_speedtest.sqlite";
	my $dbh = DBI->connect($dsn, , , {AutoCommit => 1}) or die "Cannot connect to DB";
	my $sth = $dbh->prepare("INSERT INTO speedtest VALUES (?, ?, ?, ?, ?, ?, ?)");

	$sth->execute($_[0], $_[1], $_[2], $_[3], $_[4], $_[5], $_[6]);
	$dbh->disconnect;
}



############################ Speedtesting ############################
my $speedtest = `/usr/bin/speedtest-cli --share`;

if ($speedtest =~ s/error//) { 
	UpdateDB($dato, $tid, "null", "null", "null", "null", "Failed");
	exit;
}

if ($speedtest =~ s/:\s(\d+\.\d+\sms)//) { $ping = $1; }
if ($speedtest =~ s/Download:\s(.*)\n//) { $download = $1; }
if ($speedtest =~ s/Upload:\s(.*)\n//) { $upload = $1; }
if ($speedtest =~ s/result\/(\d+)\.png//) { $share = $1; }



############################ Updating Database ############################
UpdateDB($dato, $tid, $ping, $download, $upload, $share, "OK");

