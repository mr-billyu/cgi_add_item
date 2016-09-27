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
    <html><head><title>Thank You</title></head>
    <body>
    Thank you - your form was submitted correctly!
    </body></html>
END_HTML
  }
}

#===================================================================
sub validate_form
{
  my($item);
  my($home_loc);
  my($error_message);

  $item = $query->param("Item");
  $home_loc = $query->param("home_location");

  $error_message = "";
  $error_message .= "Please enter Item<br>" if (!$item);
  $error_message .= "Please specify Home Location <br>" if (!$home_loc);

  if ($error_message)
  {
    # Errors with the form - redisplay it and return failure
    display_form($error_message, $item, $home_loc);
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

  my($home_loc_drop_down_html);
  my(@home_loc_list);
  my(@store_loc_list);
  my($loc);
  
  # Build  drop-down list
  $home_loc_drop_down_html = "";
  get_locations(\@home_loc_list, \@store_loc_list);

  foreach $loc (@home_loc_list)
  {
    $home_loc_drop_down_html .= "<option value=\"$loc\"";
    $home_loc_drop_down_html .= " selected" if ( $loc eq $home_loc );
    $home_loc_drop_down_html .= ">$loc</option>";
  }

  # Display the form
  print <<END_HTML;
  <html>
  <head><title>Form Validation</title></head>
  <body>

  <form action="store_list_add_item.pl" method="post">
  <input type="hidden" name="submit" value="Submit">

  <p>$error_message</p>

  <p>Item:<br>
  <input type="text" name="Item" value="$item">
  </p>

  <p>Home Location:<br>
  <select name="home_location">$home_loc_drop_down_html</select>
  </p>

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

