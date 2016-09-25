#!/usr/bin/env perl
use strict;
require Store_list_db;
use CGI;

my(@home_locations);
my(@store_locations);
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
  my $error_message = shift;
  my $your_name = shift;
  my $your_sex = shift;
  my $your_age = shift;

  # Remove any potentially malicious HTML tags
  $your_name =~ s/<([^>]|\n)*>//g;

  # Build "selected" HTML for the "Your Sex" radio buttons
  my $your_sex_f_sel = $your_sex eq "f" ? " checked" : "";
  my $your_sex_m_sel = $your_sex eq "m" ? " checked" : "";

  # Build "selected" HTML for the "Your Age" drop-down list
  my $your_age_html = "";
  my @your_age_opts = ( "Please select", "Under 18", "18-35", "35-55", "Over 55" );

  foreach my $your_age_option ( @your_age_opts )
  {
    $your_age_html .= "<option value=\"$your_age_option\"";
    $your_age_html .= " selected" if ( $your_age_option eq $your_age );
    $your_age_html .= ">$your_age_option</option>";
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

  <p>Your Sex:<br>
  <input type="radio" name="your_sex" value="f"$your_sex_f_sel>Female
  <input type="radio" name="your_sex" value="m"$your_sex_m_sel>Male
  </p>

  <p>Your Age:<br>
  <select name="your_age">$your_age_html</select>
  </p>

  <input type="submit" name="submit" value="Submit">

  </form>
  
  </body></html>
END_HTML

}







get_locations(\@home_locations, \@store_locations);

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

