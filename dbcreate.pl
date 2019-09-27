#!/usr/local/perl

use strict;
use warnings;
use DBI;

my $dsn = "dbi:SQLite:dbname=/home/klh/Documents/Projects/pi_speedtest/pi_speedtest.sqlite";
my $dbh = DBI->connect($dsn, , , {AutoCommit => 1}) or die "Cannot connect to DB";
$dbh->do("CREATE TABLE speedtest (epoch varchar, ping varchar, download varchar, upload varchar, share varchar, status varchar)");
my $sth = $dbh->prepare("INSERT INTO speedtest VALUES (?, ?, ?, ?, ?, ?)");


$dbh->disconnect;
