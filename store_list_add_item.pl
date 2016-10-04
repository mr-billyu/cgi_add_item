#!/usr/bin/env perl
use strict;
require Store_list_db;
use CGI;

my($query);
my($db);
my($results);
my(%data);

#
# Initialize CGI interface.
#
$query = new CGI;
print $query->header();

#
# Connect to the store list database.
#
$db = Store_list_db->new();
$results = $db->connect("/var/www/billyu.com/store_list/retro_store_list.db");

if (($results eq -1) || ($results =~ /Error/))
{
  display_form("FATAL ERROR: Invalid database file specified: $!");
  exit;
}

#
# Process form input if submitted; otherwise display it
#
if($query->param("submit"))
{
  process_form_input();
}
else
{
  display_form();
}

####################################################################
#                     Process Form Input Routines 
####################################################################

#===================================================================
sub process_form_input
{
  get_form_input();
  if(!validate_input())
  {
    display_form($data{'error message'}, $data{'item'},
                 $data{'home location'}, $data{'store location'}, 
                 $data{'stocking level'}, $data{'comment'});
    return;
  }
  update_database();
  if(verify_update())
  {
    display_form("Item has been added. Please add next item.");
  }
  else
  {
    display_form($data{'error message'});
  } 
}

#===================================================================
sub get_form_input
{
  $data{'item'} = $query->param("item");
  $data{'home location'} = $query->param("home_location");
  $data{'store location'} = $query->param("store_location");
  $data{'stocking level'} = $query->param("stocking_level");
  $data{'comment'} = $query->param("comment");
}

#===================================================================
sub validate_input
{
  $data{'error message'} = "";
  if(!$data{'item'})
  {
    $data{'error message'} .= "Please enter Item<br>";
  }

  if($db->duplicate_item($data{'item'}))
  {
    $data{'error message'} .= "Duplicate Items not allowed.";
  }

  if($data{'error message'})
  {
    return(0);
  }
  else
  {
    return(1);
  }
}

#===================================================================
sub update_database
{
  my($results);

  $data{'home location id'} = $db->get_home_loc_id($data{'home location'}); 
  $data{'store location id'} = $db->get_store_loc_id($data{'store location'});

  $results = $db->add_item($data{'item'}, $data{'home location id'},
                           $data{'store location id'},
                           $data{'stocking level'}, $data{'comment'});

  return($results);
}

#===================================================================
sub verify_update
{
  my($results);
  my(@column);

  $results = $db->get_item($data{'item'});
  (@column) = split(/\|/, $results);

  $data{'error message'} = "";

  if($column[0] != $data{'item'})
  {
    $data{'error message'} .= "item error: $column[0]\n";
  }

  if($column[1] != $data{'home location id'})
  {
    $data{'error message'} .= "home location error: $column[1]\n";
  }

  if($column[2] != $data{'store location id'})
  {
    $data{'error message'} .= "store location error: $column[2]\n";
  }

  if($column[3] != $data{'stocking level'})
  {
    $data{'error message'} .= "stocking level error: $column[3]\n";
  }

  if($column[4] != $data{'comment'})
  {
    $data{'error message'} .= "comment error: $column[4]\n";
  }

  if($data{'error message'})
  {
    return(0);
  }
  else
  {
    return(1);
  }
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
          <input type="text" name="item" value="$item" autofocus>
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
        </p>

        <p style="color:red;">$error_message</p>

  </form>
  
  </body></html>
END_HTML

}

