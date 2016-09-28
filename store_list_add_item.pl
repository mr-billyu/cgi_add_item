#!/usr/bin/env perl
use strict;
require Store_list_db;
use CGI;

my($query);

$query = new CGI;
print $query->header();

# Process form if submitted; otherwise display it
if($query->param("submit"))
{
  process_form();
}
else
{
  display_form();
}

#===================================================================
sub process_form
{
  if(validate_form())
  {
    print <<END_HTML;
    <html><head><title>Store List Add Item</title></head>
    <body>
    Item has been added. Please add next item.
    </body></html>
END_HTML
    display_form();
  }
}

#===================================================================
sub validate_form
{
  my($item);
  my($home_loc);
  my($store_loc);
  my($stocking_lvl);
  my($comment);
  my($error_message);

  $item = $query->param("Item");
  $home_loc = $query->param("home_location");
  $store_loc = $query->param("store_location");
  $stocking_lvl = $query->param("stocking_level");
  $comment = $query->param("comment");

  $error_message = "";
  $error_message .= "Please enter Item<br>" if (!$item);
  $error_message .= "Please specify Home Location <br>" if (!$home_loc);
  $error_message .= "Please specify Store Location <br>" if (!$store_loc);
  $error_message .= "Please specify Stocking Level <br>" if (!$stocking_lvl);

  if ($error_message)
  {
    # Errors with the form - redisplay it and return failure
    display_form($error_message, $item, $home_loc, $store_loc, $stocking_lvl, $comment);
    return(0);
  }
  else
  {
    # Form OK - return success
    return(1);
  }
}

#===================================================================
sub display_form
{
  # name, home_locator_id, store_locator_id, stocking_level, comment
  my($error_message) = shift;
  my($item) = shift;
  my($home_loc) = shift;
  my($store_loc) = shift;
  my($stocking_lvl) = shift;
  my($comment) = shift;

  my($home_loc_drop_down_html);
  my(@home_loc_list);
  my($store_loc_drop_down_html);
  my(@store_loc_list);
  my($loc);
  
  # Build  drop-down list
  $home_loc_drop_down_html = "";
  get_locations(\@home_loc_list, \@store_loc_list);

  foreach $loc (@home_loc_list)
  {
    $loc =~ s/\n//;
    $home_loc_drop_down_html .= "<option value=\"$loc\"";
    $home_loc_drop_down_html .= " selected" if ( $loc eq $home_loc );
    $home_loc_drop_down_html .= ">$loc</option>";
  }

  foreach $loc (@store_loc_list)
  {
    $loc =~ s/\n//;
    $store_loc_drop_down_html .= "<option value=\"$loc\"";
    $store_loc_drop_down_html .= " selected" if ( $loc eq $store_loc );
    $store_loc_drop_down_html .= ">$loc</option>";
  }

  # Display the form
  print <<END_HTML;
  <html>
  <head><title>Form Validation</title></head>
  <body>

  <form action="store_list_add_item.pl" method="post">

  <p>$error_message</p>

  <h3>Store List Add Item</h3>

  <p>Item:
  <input type="text" name="Item" value="$item">
  <br>

  Home Location:
  <select name="home_location">$home_loc_drop_down_html</select>
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

  </form>
  
  </body></html>
END_HTML

}

#===================================================================
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

