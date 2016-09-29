#!/usr/bin/env perl
use strict;
require Store_list_db;
use CGI;

my($query);
my($db);
my($results);

#
# Connect to the store list database.
#
$db = Store_list_db->new();
$results = $db->connect("retro_store_list.db");
if (($results eq -1) || ($results =~ /Error/))
{
die "Invalid database file specified: $!";
}

#
# Initialize CGI interface.
#
$query = new CGI;
print $query->header();

#
# Process form if submitted; otherwise display it
#
if($query->param("submit"))
{
  process_form();
}
else
{
  display_form();
}

####################################################################
#                     Form Processing Routines
####################################################################

#===================================================================
sub process_form
{
  if(validate_form())
  {
    display_form("Item has been added. Please add next item.");
  }
}

#===================================================================
sub validate_form
{
  my($item);
  my($home_loc);
  my($home_loc_id);
  my($store_loc);
  my($store_loc_id);
  my($stocking_lvl);
  my($comment);
  my($error_message);

  #
  # Get the input parameters from the form
  #
  $item = $query->param("Item");
  $home_loc = $query->param("home_location");
  $store_loc = $query->param("store_location");
  $stocking_lvl = $query->param("stocking_level");
  $comment = $query->param("comment");

  $error_message = "";
  $error_message .= "Please enter Item<br>" if (!$item);

  if ($error_message)
  {
    display_form($error_message, $item, $home_loc, $store_loc, 
                 $stocking_lvl, $comment);
    return(0);
  }

  #
  # Get the home and store location ids
  #
  $home_loc_id = $db->get_home_loc_id($home_loc); 
  $store_loc_id = $db->get_store_loc_id($store_loc);

  return(1);
}

####################################################################
#                       Form Display Routines
####################################################################
#===================================================================
sub display_form
{
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
  
  #
  # Build  home_location drop down list
  #
  $home_loc_drop_down_html = "";
  (@home_loc_list) = $db->get_home_locations();
  foreach $loc (@home_loc_list)
  {
    $loc =~ s/\n//;
    $home_loc_drop_down_html .= "<option value=\"$loc\"";
    $home_loc_drop_down_html .= " selected" if ( $loc eq $home_loc );
    $home_loc_drop_down_html .= ">$loc</option>";
  }

  #
  # Build store_location drop down list
  #
  $store_loc_drop_down_html = "";
  (@store_loc_list) = $db->get_store_locations();
  foreach $loc (@store_loc_list)
  {
    $loc =~ s/\n//;
    $store_loc_drop_down_html .= "<option value=\"$loc\"";
    $store_loc_drop_down_html .= " selected" if ( $loc eq $store_loc );
    $store_loc_drop_down_html .= ">$loc</option>";
  }

  #
  # Output the html code to display the form 
  #
  print <<END_HTML;
  <html>
  <head><title>Form Validation</title></head>
  <body>

  <form action="store_list_add_item.pl" method="post">

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

  <p style="color:red;">$error_message</p>

  </form>
  
  </body></html>
END_HTML

}

