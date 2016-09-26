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

sub validate_form
{
  my $your_name = $query->param("your_name");
  my $your_sex = $query->param("your_sex");
  my $your_age = $query->param("your_age");

  my $error_message = "";

  $error_message .= "Please enter your name<br>" if (!$your_name);
  $error_message .= "Please specify your sex<br>" if (!$your_sex);
  $error_message .= "Please specify your age<br>" if ($your_age eq "Please select");

  if ($error_message)
  {
    # Errors with the form - redisplay it and return failure
    display_form($error_message, $your_name, $your_sex, $your_age);
    return(0);
  }
  else
  {
    # Form OK - return success
    return(1);
  }
}

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

  <form action="reentrant.pl" method="post">
  <input type="hidden" name="submit" value="Submit">

  <p>$error_message</p>

  <p>Your Name:<br>
  <input type="text" name="your_name" value="$your_name">
  </p>

  <p>Your Age:<br>
  <select name="your_age">$your_age_html</select>
  </p>

  <input type="submit" name="submit" value="Submit">

  </form>
  
  </body></html>
END_HTML

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

