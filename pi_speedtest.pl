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



############################ Database SUB ############################
sub UpdateDB {
	my $dsn = "dbi:SQLite:dbname=/home/klh/Documents/Projects/pi_speedtest/pi_speedtest.sqlite";
	my $dbh = DBI->connect($dsn, , , {AutoCommit => 1}) or die "Cannot connect to DB";
	my $sth = $dbh->prepare("INSERT INTO speedtest VALUES (?, ?, ?, ?, ?, ?, ?)");

	$sth->execute($_[0], $_[1], $_[2], $_[3], $_[4], $_[5], $_[6]);
	$dbh->disconnect;
}

############################ GPIO LED SUB ############################
sub GPIOLeds {
	print "Setting GPIO LED $_[0] TO: $_[1]\n";
}



############################ Speedtesting ############################
open(SPEEDTEST_CLI, "/usr/bin/speedtest-cli --share|");

GPIOLeds("IDLE","OFF");
GPIOLeds("TESTING","ON");

while (<SPEEDTEST_CLI>) {
	#print;

	if ($_ =~ s/error//) { 
		UpdateDB($dato, $tid, "null", "null", "null", "null", "Failed");
		exit;
	}

	if ($_ =~ s/:\s(\d+\.\d+\sms)//) {
		$ping = $1; 
		GPIOLeds("DOWNLOADING","ON");
	}

	if ($_ =~ s/Download:\s(.*)\n//) {
		$download = $1;
		GPIOLeds("DOWNLOADING","OFF");
		GPIOLeds("UPLOADING","ON");
	}

	if ($_ =~ s/Upload:\s(.*)\n//) {
		$upload = $1;
		GPIOLeds("UPLOADING","OFF");
		GPIOLeds("TESTING","OFF");

	}

	if ($_ =~ s/result\/(\d+)\.png//) {
		$share = $1;
	}

}
close(SPEEDTEST_CLI);



############################ Updating Database ############################
UpdateDB($dato, $tid, $ping, $download, $upload, $share, "OK");

GPIOLeds("DONE","ON");
sleep 5;
GPIOLeds("DONE","OFF");
GPIOLeds("IDLE","ON");
