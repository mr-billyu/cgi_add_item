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

sub get_home_loc_id {
	my($self, $home_loc) = @_;
	my(@results);
	my($cmd) = "select home_locator_id from home_locator \
                where name = \"$home_loc\";";

	(@results) = `sqlite3 $self->{database} '$cmd'`;
	return($results[0]);
}

sub get_store_locations {
	my($self) = @_;
	my(@results);
	my($cmd) = "select name from store_locator;";

	(@results) = `sqlite3 $self->{database} '$cmd'`;
	return(@results);
}

sub get_store_loc_id {
	my($self, $store_loc) = @_;
	my(@results);
	my($cmd) = "select store_locator_id from store_locator \
                where name = \"$store_loc\";";

	(@results) = `sqlite3 $self->{database} '$cmd'`;
	return($results[0]);
}

sub add_item {
	my($self, $item, $home_loc_id, $store_loc_id, $stocking_lvl, 
       $comment) = @_;

    my($cmd);

    $cmd = "insert into item 
            (name, home_locator_id, store_locator_id, 
             stocking_level, comment)
            values (\"$item\", \"$home_loc_id\", \"$store_loc_id\", 
             \"$stocking_lvl\", \"$comment\")";

	`sqlite3 $self->{database} '$cmd'`;

    return();
}

sub get_all_items {
	my($self) = @_;
	my(@results);
	my($cmd) = "select * from item";
	
	(@results)= `sqlite3 $self->{database} '$cmd'`;
	return(@results);
}

sub get_item {
	my($self, $item) = @_;
	my(@results);
	my($cmd) = "select * from item \
                where name = \"$item\";";

	(@results) = `sqlite3 $self->{database} '$cmd'`;
	return($results[0]);
}

sub duplicate_item {
	my($self, $item) = @_;
	my($cmd) = "select name from item \
                where name = \"$item\";";

	if( `sqlite3 $self->{database} '$cmd'`)
    {
        return(1);
    }
    else
    {
    	return(0);
    }
}
1;

