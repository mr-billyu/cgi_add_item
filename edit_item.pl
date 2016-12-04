#!/usr/bin/env perl
use strict;
use CGI;
use DBI;

my($item_form);
my($dbh);
my($qryh);
my(%data);

#
# Initialize CGI interface.
#
$item_form = new CGI;
print $item_form->header();

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
if($item_form->param("submit"))
{
  process_form_input();
}
else
{
  display_form();
}

$dbh->disconnect();

####################################################################
#                     Process Form Input Routines 
####################################################################

#===================================================================
sub process_form_input
{
  get_form_input();
  if(!validate_input())
  {
    display_form($data{error_message}, $data{item},
                 $data{home_location}, $data{store_location}, 
                 $data{stocking_level}, $data{comment});
    return;
  }
  update_database();
  if(verify_update())
  {
    display_form("Item has been added. Please add next item.");
  }
  else
  {
    display_form($data{error_message});
  } 
}

#===================================================================
sub get_form_input
{
  $data{item} = $item_form->param("item");
  $data{home_location} = $item_form->param("home_location");
  $data{store_location} = $item_form->param("store_location");
  $data{stocking_level} = $item_form->param("stocking_level");
  $data{comment} = $item_form->param("comment");
}

#===================================================================
sub validate_input
{
  my($stmt);
  my(@row);
  
  $data{error_message} = "";
  if(!$data{item})
  {
    $data{error_message} .= "Please enter Item<br>";
  }

  $stmt = qq(select name from item
             where name = ?;);
  $qryh = $dbh->prepare($stmt);
  $qryh->execute($data{item});
  @row = $qryh->fetchrow_array();
  if(@row)
  {
	  if ($row[0] == $data{item})
	  {
		$data{error_message} .= "Duplicate Items not allowed.";
	  }
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
sub update_database
{
	my($stmt);
	my(@row);
	
	$stmt = qq(select home_locator_id from home_locator
			   where name = ?;);
	$qryh = $dbh->prepare($stmt);
	$qryh->execute($data{home_location});
	@row = $qryh->fetchrow_array();
	$data{home_location_id} = $row[0];
	
	$stmt = qq(select store_locator_id from store_locator
	           where name = ?;);
	$qryh = $dbh->prepare($stmt);
	$qryh->execute($data{store_location});
	@row = $qryh->fetchrow_array();
	$data{store_location_id} = $row[0];

	$stmt = qq(insert into item (name, home_locator_id,
	           store_locator_id, stocking_level, comment) values
	           ("$data{item}", "$data{home_location_id}", 
	            "$data{store_location_id}", "$data{stocking_level}",
	            "$data{comment}"));
	$dbh->do($stmt);
}

#===================================================================
sub verify_update
{
  my($stmt);
  my(@row);
  
  $stmt = qq(select * from item where name = ?);
  $qryh = $dbh->prepare($stmt);
  $qryh->execute($data{item});
  @row = $qryh->fetchrow_array();
  
  $data{error_message} = "";

  if($row[0] != $data{item})
  {
    $data{error_message} .= "item error: $row[0]\n";
  }

  if($row[1] != $data{home_location_id})
  {
    $data{error_message} .= "home location error: $row[1]\n";
  }

  if($row[2] != $data{store_location_id})
  {
    $data{error_message} .= "store location error: $row[2]\n";
  }

  if($row[3] != $data{stocking_level})
  {
    $data{error_message} .= "stocking level error: $row[3]\n";
  }

  if($row[4] != $data{comment})
  {
    $data{error_message} .= "comment error: $row[4]\n";
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
  my($store_loc_drop_down_html);
  my($stmt);
  my(@row);
  
  #
  # Build  home_location drop down list
  #
  $home_loc_drop_down_html = "";
  $stmt = qq(select name from home_locator;);
  $qryh = $dbh->prepare($stmt);
  $qryh->execute();
  while(@row = $qryh->fetchrow_array())
  {
    $home_loc_drop_down_html .= "<option value=\"$row[0]\"";
    $home_loc_drop_down_html .= " selected" if ( $row[0] eq $home_loc );
    $home_loc_drop_down_html .= ">$row[0]</option>";
  }

  #
  # Build store_location drop down list
  #
  $store_loc_drop_down_html = "";
  $stmt = qq(select name from store_locator;);
  $qryh = $dbh->prepare($stmt);
  $qryh->execute();
  while(@row = $qryh->fetchrow_array())
  {
    $store_loc_drop_down_html .= "<option value=\"$row[0]\"";
    $store_loc_drop_down_html .= " selected" if ( $row[0] eq $store_loc );
    $store_loc_drop_down_html .= ">$row[0]</option>";
  }

  #
  # Output the html code to display the form 
  #
  print <<END_HTML;
  <html>
    <head><title>Form Validation</title></head>
    <body>

      <form action="edit_item.pl" method="post">
      <input type="hidden" name="process" value="item_form">

        <h3>Store List Edit Item</h3>

        <p>
          Item:
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
    </body>
  </html>
END_HTML

}

