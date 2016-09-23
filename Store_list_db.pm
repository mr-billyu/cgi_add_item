#!/usr/bin/env perl
package Store_list_db;
use strict;

sub new {
    my($class) = shift; # $_[0] contains class name
    my($self) = {}; # Reference to hash which holds instance data

    bless($self, $class); # Make $self an instance of class $class 
    return($self); # Constructor always returns a blessed instance
}

sub connect {
	my($self, $database) = @_;
    my($results);
    my($cmd) = "pragma schema_version;";

	if(-f $database) 
	{ 
	    $results = `sqlite3 $database '$cmd' 2>&1`;
		$self->{database} = $database;
    } 
	else 
	{
		$results = -1;
	}
	return($results);
}

sub get_home_locations {
	my($self) = @_;
	my(@results);
	my($cmd) = "select name from home_locator;";

	(@results) = `sqlite3 $self->{database} '$cmd'`;
	return(@results);
}

sub get_store_locations {
	my($self) = @_;
	my(@results);
	my($cmd) = "select name from store_locator;";

	(@results) = `sqlite3 $self->{database} '$cmd'`;
	return(@results);
}

sub add_item {
	my($self, $item, $home_locator, $store_locator, $stocking_level, 
       $comment) = @_;
}
1;

