#!/usr/bin/env perl
package Store_list_dump_item_scrn_1;
use strict;

#=======================================================================
#Dump store list item table
#
#	display_form
#		Inputs:
#			Pointer to store list db object
#			string containing message (optional)
#
#		Outputs:
#
#		Messages:
#			1: Ok
#
#		Description:
#			Display all items from the item table.
#=======================================================================

use Store_list_db;

sub display_form
{
	my($db, $error_message) = @_;
	my(@items);
	my($row);
	my($i);
  
	#
	# Get all items.
	#
	@items = $db->get_all_items();

	#
	# Output the html code to display the form 
	#
	print <<HEADER;
	<html>
		<head><title>Form Validation</title></head>
		<body>
			<form action="dump_item.pl" method="post">
				<h3>Dump Item</h3>  
HEADER

	$i = 1;
	foreach $row (@items)
	{
		print("$i $row <br>");
		$i++;
	}

	print <<FOOTER;
				<input type="submit" name="submit" value="Submit">
				<p style="color:red;">$error_message</p>
			</form>
		</body>
	</html>
FOOTER
	return(1);
}
1
