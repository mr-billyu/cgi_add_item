#!/usr/bin/env perl
use strict;
use CGI;
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);
use DBI;

my($forms);
my($dbh);
my(%data);

#
# Initialize CGI interface.
#
$forms = new CGI;

#
# Connect to the store list database.
#
$dbh = DBI->connect("DBI:SQLite:dbname=/var/www/billyu.com/test_store_list.db")
          or die $DBI::errstr;
$dbh->{RaiseError} = 0;
$dbh->{AutoCommit} = 1;

#
# Process form input if submitted; otherwise display it
#
if($forms->param("submit"))
{
  if($forms->param("form") eq "item")
  {
    process_item_form_input();
  }
  else
  {
    process_edit_form_input();
  }
}
else
{
  display_forms("item");
}

$dbh->disconnect();


####################################################################
#                     Process Item Form Input Routines 
####################################################################
#===================================================================
sub process_item_form_input
{
  get_item_form_input();
  if(!validate_item_form_input())
  {
    display_forms("item", $data{error_message}, $data{item});
    return;
  }
  get_item_data();
  display_forms("edit", $data{error_message}, $data{item},
                 $data{home_location}, $data{store_location}, 
                 $data{stocking_level}, $data{comment});
}

#===================================================================
sub get_item_form_input
{
  $data{item} = $forms->param("item");
}

#===================================================================
sub validate_item_form_input
{
  my($stmt);
  my(@row);
  
  $data{error_message} = "";
  if(!$data{item})
  {
    $data{error_message} .= "Please enter Item<br>";
  }

  $stmt = $dbh->prepare(qq:
                        select name from item
                        where name = ?;
                        :);
  $stmt->execute($data{item});
  @row = $stmt->fetchrow_array();
  $stmt->finish();
  if ($row[0] ne $data{item})
  {
     $data{error_message} .= "Item not found";
  }

  if($data{error_message})
  {
    return(0);
  }
  else
  {
    return(1);
  }
}

#===================================================================
sub get_item_data
{
  my($stmt);
  my(@item_row);
  my(@locator_row);

  $stmt = $dbh->prepare(qq:
                        select * from item where name = ?
                        :);
  $stmt->execute($data{item});
  @item_row = $stmt->fetchrow_array();
  $stmt->finish();
  
  $stmt = $dbh->prepare(qq:
                        select name from home_locator
                        where home_locator_id = ?;
                        :);
  $stmt->execute($item_row[1]);
  @locator_row = $stmt->fetchrow_array();
  $stmt->finish();
  $data{home_location} = $locator_row[0];

  $stmt = $dbh->prepare(qq:
                        select name from store_locator
                        where store_locator_id = ?;
                        :);
  $stmt->execute($item_row[2]);
  @locator_row = $stmt->fetchrow_array();
  $stmt->finish();
  $data{store_location} = $locator_row[0];

  $data{stocking_level} = $item_row[3];
  $data{comment} = $item_row[4];

}

####################################################################
#                     Process Edit Form Input Routines 
####################################################################
#===================================================================
sub process_edit_form_input
{
  get_edit_form_input();
  update_database();
  if(verify_update())
  {
    display_forms("item", "Item has been updated. Please enter next item.");
  }
  else
  {
    display_forms("edit", $data{error_message});
  } 
}

#===================================================================
sub get_edit_form_input
{
  $data{item} = $forms->param("item");
  $data{home_location} = $forms->param("home_location");
  $data{store_location} = $forms->param("store_location");
  $data{stocking_level} = $forms->param("stocking_level");
  $data{comment} = $forms->param("comment");
}

#===================================================================
sub update_database
{
	my($stmt);
	my(@row);
	
	$stmt = $dbh->prepare(qq:
	                      select home_locator_id from home_locator
		                  where name = ?;
		                  :);
	$stmt->execute($data{home_location});
	@row = $stmt->fetchrow_array();
	$stmt->finish();
	$data{home_location_id} = $row[0];
	
	$stmt = $dbh->prepare(qq:
	                      select store_locator_id from store_locator
	                      where name = ?;
	                      :);
	$stmt->execute($data{store_location});
	@row = $stmt->fetchrow_array();
	$stmt->finish();
	$data{store_location_id} = $row[0];

	$stmt = $dbh->prepare(qq:
	                      update item 
	                      set home_locator_id = ?,
	                      store_locator_id = ?,
	                      stocking_level = ?,
	                      comment = ?
	                      where name = ?;
	                      :);
	$stmt->execute("$data{home_location_id}", 
	               "$data{store_location_id}", "$data{stocking_level}",
	               "$data{comment}", "$data{item}");
	$stmt->finish();
}

#===================================================================
sub verify_update
{
  my($stmt);
  my(@item_row);
  my(@locator_row);
  
  $stmt = $dbh->prepare(qq:
                        select * from item where name = ?
                        :);
  $stmt->execute($data{item});
  @item_row = $stmt->fetchrow_array();
  $stmt->finish();
  
  $data{error_message} = "";

  if($item_row[0] ne $data{item})
  {
    $data{error_message} .= "item error: $item_row[0]\n";
  }

  $stmt = $dbh->prepare(qq:
                        select name from home_locator
                        where home_locator_id = ?;
                        :);
  $stmt->execute($item_row[1]);
  @locator_row = $stmt->fetchrow_array();
  $stmt->finish();
  if($locator_row[0] ne $data{home_location})
  {
    $data{error_message} .= "home location error: $locator_row[0]\n";
  }

  $stmt = $dbh->prepare(qq:
                        select name from store_locator
                        where store_locator_id = ?;
                        :);
  $stmt->execute($item_row[2]);
  @locator_row = $stmt->fetchrow_array();
  $stmt->finish();
  if($locator_row[0] ne $data{store_location})
  {
    $data{error_message} .= "store location error: $locator_row[0]\n";
  }

  if($item_row[3] != $data{stocking_level})
  {
    $data{error_message} .= "stocking level error: $item_row[3]\n";
  }

  if($item_row[4] ne $data{comment})
  {
    $data{error_message} .= "comment error: $item_row[4]\n";
  }

  if($data{error_message})
  {
    return(0);
  }
  else
  {
    return(1);
  }
}

####################################################################
#                       Display Forms Routines
####################################################################
#===================================================================
sub display_forms()
{
  my($type) = shift;
  my($error_message) = shift;
  my($item) = shift;
  my($home_loc) = shift;
  my($store_loc) = shift;
  my($stocking_lvl) = shift;
  my($comment) = shift;
  
  if($type eq "item")
  {
    display_item_form($error_message, $item);
  }
  else
  {
    display_edit_form($error_message, $item, $home_loc, $store_loc,
                      $stocking_lvl, $comment);
  }
}

#===================================================================
sub display_item_form
{
  my($error_message) = shift;
  my($item) = shift;
  
  #
  # Output the html code to display the item form 
  #
  print $forms->header();
  print <<END_HTML;
  <html>
  
    <head>
      <title>
        Item Form
      </title>
    </head>
    
    <body>
      <form action="edit_item.pl" method="post">
      <input type="hidden" name="form" value="item">

        <h3>
          Store List Edit Item
        </h3>

        <p>
          Item:
          <input type="text" name="item" value="$item" autofocus>
          <br>

          <input type="submit" name="submit" value="Submit">
        </p>

        <p style="color:red;">
          $error_message
        </p>

      </form>
    </body>
  </html>
END_HTML

}

#===================================================================
sub display_edit_form
{
  my($error_message) = shift;
  my($item) = shift;
  my($home_loc) = shift;
  my($store_loc) = shift;
  my($stocking_lvl) = shift;
  my($comment) = shift;

  my($home_loc_drop_down_html);
  my($store_loc_drop_down_html);
  my($stmt);
  my(@row);
  
  #
  # Build  home_location drop down list
  #
  $home_loc_drop_down_html = "";
  $stmt = $dbh->prepare(qq:
                        select name from home_locator;
                        :);
  $stmt->execute();
  while(@row = $stmt->fetchrow_array())
  {
    $home_loc_drop_down_html .= "<option value=\"$row[0]\"";
    $home_loc_drop_down_html .= " selected" if ( $row[0] eq $home_loc );
    $home_loc_drop_down_html .= ">$row[0]</option>";
  }
  $stmt->finish();

  #
  # Build store_location drop down list
  #
  $store_loc_drop_down_html = "";
  $stmt = $dbh->prepare(qq:
                        select name from store_locator;
                        :);
  $stmt->execute();
  while(@row = $stmt->fetchrow_array())
  {
    $store_loc_drop_down_html .= "<option value=\"$row[0]\"";
    $store_loc_drop_down_html .= " selected" if ( $row[0] eq $store_loc );
    $store_loc_drop_down_html .= ">$row[0]</option>";
  }
  $stmt->finish();

  #
  # Output the html code to display the form 
  #
  print $forms->header();
  
  print <<END_HTML;
  <html>
  
    <head>
      <title>
        Edit Form
      </title>
    </head>
    
    <body>
      <form action="edit_item.pl" method="post">
      <input type="hidden" name="form" value="edit">

        <h3>
          Store List Edit Item
        </h3>

        <p contenteditable=false>
          Item: $item
          <input type="text" name="item" value="$item" readonly>
          <br>

          Home Location:
          <select name="home_location">$home_loc_drop_down_html </select>
          <br> 

          Store Location:
          <select name="store_location">$store_loc_drop_down_html</select>
          <br>

          Stocking Level:
          <input type="text" name="stocking_level" value="$stocking_lvl">
          <br>

          Comment:
          <input type="text" name="comment" value="$comment">
          <br>

          <input type="submit" name="submit" value="Submit">
        </p>

        <p style="color:red;">
          $error_message
        </p>

      </form>
    </body>
  </html>
END_HTML

}

