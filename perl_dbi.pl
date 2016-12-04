#!/usr/bin/env perl
 
use DBI;
use strict;
 
my($dbh);
my($stmt);
my($obj);

$dbh = DBI->connect("DBI:SQLite:dbname=/var/www/billyu.com/xmodulo.db")
					or die $DBI::errstr;
$dbh->{RaiseError} = 1;
$dbh->{AutoCommit} = 1;
print STDERR "Database opened successfully\n";
 
# create a table
my $stmt = qq(CREATE TABLE IF NOT EXISTS NETWORK
             (ID INTEGER PRIMARY KEY     AUTOINCREMENT,
              HOSTNAME       TEXT    NOT NULL,
              IPADDRESS      INT     NOT NULL,
              OS             CHAR(50),
              CPULOAD        REAL););
$dbh->do($stmt);
print STDERR "Table created successfully\n";
 
# insert three rows into the table
$stmt = qq(INSERT INTO NETWORK (HOSTNAME,IPADDRESS,OS,CPULOAD)
           VALUES ('xmodulo', 16843009, 'Ubuntu 14.10', 0.0));
$dbh->do($stmt);
 
$stmt = qq(INSERT INTO NETWORK (HOSTNAME,IPADDRESS,OS,CPULOAD)
           VALUES ('bert', 16843010, 'CentOS 7', 0.0));
$dbh->do($stmt);
 
$stmt = qq(INSERT INTO NETWORK (HOSTNAME,IPADDRESS,OS,CPULOAD)
           VALUES ('puppy', 16843011, 'Ubuntu 14.10', 0.0));
$dbh->do($stmt);
 
# search and iterate row(s) in the table
$stmt = qq(SELECT id, hostname, os, cpuload from NETWORK;);
$obj = $dbh->prepare($stmt);
$obj->execute();
 
while(my @row = $obj->fetchrow_array()) {
      print "ID: ". $row[0] . "\n";
      print "HOSTNAME: ". $row[1] ."\n";
      print "OS: ". $row[2] ."\n";
      print "CPULOAD: ". $row[3] ."\n\n";
}
 
# update specific row(s) in the table
$stmt = qq(UPDATE NETWORK set CPULOAD = 50 where OS='Ubuntu 14.10';);
$dbh->do($stmt);
 
# delete specific row(s) from the table
$stmt = qq(DELETE from NETWORK where ID=2;);
$dbh->do($stmt);
 
# quit the database
$dbh->disconnect();
