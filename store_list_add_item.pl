#!/usr/bin/env perl
use strict;
require Store_list_db;

my(@home_locations);
my(@store_locations);

get_locations(\@home_locations, \@store_locations);
my($i);
my($rcd);
$i=0;
foreach $rcd (@home_locations)
{
	print $i++;
	print $rcd;
}

$i=0;
foreach $rcd (@store_locations)
{
	print $i++;
	print $rcd;
}

exit(0);

sub get_locations
{
	my($home_locations) = shift;
	my($store_locations) = shift;
	my($db);
	my($results);
	$db = Store_list_db->new();
	$results = $db->connect("retro_store_list.db");
	if (($results eq -1) || ($results =~ /Error/))
	{
		die "Invalid database file specified: $!";
	}
	(@$home_locations) = $db->get_home_locations();
	(@$store_locations) = $db->get_store_locations();
}

