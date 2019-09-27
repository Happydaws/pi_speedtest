#!/usr/bin/perl

############################ Setting Variables ############################
use strict;
use warnings;
use DBI;
use RPi::Pin;
use RPi::Const qw(:all);

my ($ping, $download, $upload, $share);



############################ Setting Date / Time ############################
my $epoch = time;


############################ Database SUB ############################
sub UpdateDB {
	my $dsn = "dbi:SQLite:dbname=pi_speedtest.sqlite";
	my $dbh = DBI->connect($dsn, , , {AutoCommit => 1}) or die "Cannot connect to DB";
	my $sth = $dbh->prepare("INSERT INTO speedtest VALUES (?, ?, ?, ?, ?, ?)");

	$sth->execute($_[0], $_[1], $_[2], $_[3], $_[4], $_[5]);
	$dbh->disconnect;
}

############################ GPIO LED SUB ############################
sub GPIOLeds {
	my $pin = RPi::Pin->new($_[0]);
	$pin->mode(OUTPUT);
	$pin->write($_[1]);
}



############################ Speedtesting ############################
open(SPEEDTEST_CLI, "/usr/bin/speedtest-cli --share|");

GPIOLeds("6","0"); ### SET Idle OFF
GPIOLeds("21","1"); ### SET Testing ON

while (<SPEEDTEST_CLI>) {
	#print;

	if ($_ =~ s/error//) { 
		UpdateDB($epoch, "null", "null", "null", "null", "Failed");
		exit;
	}

	if ($_ =~ s/:\s(\d+\.\d+\sms)//) {
		$ping = $1; 
		GPIOLeds("20","1"); ### SET Download ON
	}

	if ($_ =~ s/Download:\s(.*)\n//) {
		$download = $1;
		GPIOLeds("20","0"); ### SET Download OFF
		GPIOLeds("13","1"); ### SET Upload ON
	}

	if ($_ =~ s/Upload:\s(.*)\n//) {
		$upload = $1;
		GPIOLeds("13","0"); ### SET Upload OFF
		GPIOLeds("21","0"); ### SET Testing OFF

	}

	if ($_ =~ s/result\/(\d+)\.png//) {
		$share = $1;
	}

}
close(SPEEDTEST_CLI);



############################ Updating Database ############################
UpdateDB($epoch, $ping, $download, $upload, $share, "OK");

GPIOLeds("19","1"); ### SET Done ON
sleep 5;
GPIOLeds("19","0"); ### SET Done OFF
GPIOLeds("6","1"); ### SET IDLE ON
