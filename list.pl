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
  get_item_form_input();
}
else
{
  display_item_form("item");
}

$dbh->disconnect();


####################################################################
#                     Process Item Form Input Routines 
####################################################################

#===================================================================
sub get_item_form_input
{
  my($mdbh);
  my($stmt);
  my($stmt2);
  my($stmt3);
  my($stmt4);
  my($size);
  my($i);
  my($rcd);
  my(@row);
  
  # Use [] to create an array reference ($ref = [];) vs
  # () to create an array (@array = ();).
  $data{qty} = [];
  $data{item} = [];
  $data{note} = [];

  # Anywhere you can put an identifier as part of a variable,
  # you can replace the identifier with a BLOCK, {}, returning
  # a reference of the correct type. So in the following 
  # statement, {$data{qty}} is equivalent to a scalar containing
  # a reference, @$scalar = ();
  @{$data{qty}} = $forms->param("qty");
  @{$data{item}} = $forms->param("item");
  @{$data{note}} = $forms->param("note");
  
  print "Content-type: text/html\n\n";

  # Create temporary database in memory to construct the store list.
  $mdbh = DBI->connect("DBI:SQLite:dbname=:memory:")
            or die $DBI::errstr;
  $mdbh->{RaiseError} = 0;
  $mdbh->{AutoCommit} = 1;
  $stmt = $mdbh->prepare(qq:
                         create table list_item (
                         item              text,
                         qty               integer,
                         note              text,
                         comment           text,
                         sequence          integer,
                         store_location    text);
                         :);
  $stmt->execute();
  $stmt->finish();
                        
  # Prepare statement to get item data from $dbh that needs to
  # be stored in the temporary $mdbh
  $stmt2 = $dbh->prepare(qq:
                         select comment, sequence, store_locator.name
                         from item, store_locator
                         where item.name = ?
                         and item.store_locator_id = store_locator.store_locator_id;
                         :);
                         
  # Prepare statement to insert data into temporary store list.
  $stmt3 = $mdbh->prepare(qq:
                          insert into list_item
                          (item , qty, note, comment, sequence, 
                          store_location)
                          values ( ?, ?, ?, ?, ?, ?);
                          :);

  $size = @{$data{qty}};
  $i = 0;
  while($i < $size) {
    if(${$data{qty}}[$i] > 0) {
      # get all the data from $dbh so that it can be stored in
      # $mdbh.
      $stmt2->execute(${$data{item}}[$i]);
      @row = $stmt2->fetchrow_array();

      # Store store list line in temporary database.
      $stmt3->execute(${$data{item}}[$i], ${$data{qty}}[$i],
                      ${$data{note}}[$i], $row[0], $row[1], $row[2]);
    }
    $i++;
  }
  $stmt2->finish();
  $stmt3->finish();
  
  # Get store list data from temporary database
  $stmt4 = $mdbh->prepare(qq:
                          select store_location, qty, item, 
                          comment, note
                          from list_item
                          order by sequence, item;
                         :);
  $stmt4->execute();
  
#  print "Content-Type: text/html\n\n";
  print "<pre> \n";
  while(@row = $stmt4->fetchrow_array()) {
    printf "___ %9.9s %3d %-s\n", 
          $row[0], $row[1], $row[2];
    if($row[3] ne "") {
      printf "                     Comment: $row[3]\n";
    }
    if($row[4] ne "") {
      printf "                     Note: $row[4]\n";
    }
  }
  print "</pre>";
  $stmt4->finish();

  $mdbh->disconnect();
}

####################################################################
#                       Display Forms Routines
####################################################################
#===================================================================
sub display_item_form
{
  my($error_message) = shift;
  
  my($stmt);
  my(@row);
  my($i);
  my(@qty);
  my(@note);
  
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
    
    <style>
      table, th, td {
	    border: 1px solid gray;
	   }
	</style>
	      
    <body>
      <form action="list.pl" method="post">
      <input type="hidden" name="form" value="item">

        <h3>
          Store List Edit Item
        </h3>
        
        <table>
		  <tr>
		    <th align="left">Loc</th>
		    <th align="left">Qty</th>
		    <th align="left">Item</th>
		    <th align="left">Stk Lvl</th>
		    <th align="left">Comment</th>
		    <th align="left">Note</th>
		  </tr>
END_HTML


  $stmt = $dbh->prepare(qq:
                        select home_locator.name, item.name, 
                          stocking_level, comment, store_locator.name,
                          sequence
                        from item, home_locator, store_locator
                        where item.home_locator_id = home_locator.home_locator_id
                          and item.store_locator_id = store_locator.store_locator_id
                        order by home_locator.name, item.name;
                        :);
  $stmt->execute();
  $i= 0;
  while(@row = $stmt->fetchrow_array())
  {
	print(qq:
		  <tr>
			<td>$row[0]</td>
			<td><input type="text" name="qty" value="$qty[$i]" size="3"></td>
			<td>$row[1]</td>
			<td>$row[2]</td>
			<td>$row[3]</td>
			<td><input type="text" name="note" value="$note[$i]" size="30"></td>
		  </tr>
      <input type="hidden" name="item" value="$row[1]">
		  :);
    $i++;
  }
  $stmt->finish();

  print <<END_HTML;
		</table>
        <p>
          Item:
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

