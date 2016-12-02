#!/usr/bin/env perl
 
use DBI;
use strict;
 
# define database name and driver
my $driver   = "SQLite";
my $db_name = "xmodulo.db";
my $dbd = "DBI:$driver:dbname=$db_name";
 
# sqlite does not have a notion of username/password
my $username = "";
my $password = "";
 
# create and connect to a database.
# this will create a file named xmodulo.db
my $dbh = DBI->connect($dbd, $username, $password, { RaiseError => 1 })
                      or die $DBI::errstr;
print STDERR "Database opened successfully\n";
 
# create a table
my $stmt = qq(CREATE TABLE IF NOT EXISTS NETWORK
             (ID INTEGER PRIMARY KEY     AUTOINCREMENT,
              HOSTNAME       TEXT    NOT NULL,
              IPADDRESS      INT     NOT NULL,
              OS             CHAR(50),
              CPULOAD        REAL););
my $ret = $dbh->do($stmt);
if($ret < 0) {
   print STDERR $DBI::errstr;
} else {
   print STDERR "Table created successfully\n";
}
 
# insert three rows into the table
$stmt = qq(INSERT INTO NETWORK (HOSTNAME,IPADDRESS,OS,CPULOAD)
           VALUES ('xmodulo', 16843009, 'Ubuntu 14.10', 0.0));
$ret = $dbh->do($stmt) or die $DBI::errstr;
 
$stmt = qq(INSERT INTO NETWORK (HOSTNAME,IPADDRESS,OS,CPULOAD)
           VALUES ('bert', 16843010, 'CentOS 7', 0.0));
$ret = $dbh->do($stmt) or die $DBI::errstr;
 
$stmt = qq(INSERT INTO NETWORK (HOSTNAME,IPADDRESS,OS,CPULOAD)
           VALUES ('puppy', 16843011, 'Ubuntu 14.10', 0.0));
$ret = $dbh->do($stmt) or die $DBI::errstr;
 
# search and iterate row(s) in the table
$stmt = qq(SELECT id, hostname, os, cpuload from NETWORK;);
my $obj = $dbh->prepare($stmt);
$ret = $obj->execute() or die $DBI::errstr;
 
if($ret < 0) {
   print STDERR $DBI::errstr;
}
while(my @row = $obj->fetchrow_array()) {
      print "ID: ". $row[0] . "\n";
      print "HOSTNAME: ". $row[1] ."\n";
      print "OS: ". $row[2] ."\n";
      print "CPULOAD: ". $row[3] ."\n\n";
}
 
# update specific row(s) in the table
$stmt = qq(UPDATE NETWORK set CPULOAD = 50 where OS='Ubuntu 14.10';);
$ret = $dbh->do($stmt) or die $DBI::errstr;
 
if( $ret < 0 ) {
   print STDERR $DBI::errstr;
} else {
   print STDERR "A total of $ret rows updated\n";
}
 
# delete specific row(s) from the table
$stmt = qq(DELETE from NETWORK where ID=2;);
$ret = $dbh->do($stmt) or die $DBI::errstr;
 
if($ret < 0) {
   print STDERR $DBI::errstr;
} else {
   print STDERR "A total of $ret rows deleted\n";
}
 
# quit the database
$dbh->disconnect();
print STDERR "Exit the database\n";
