#!/usr/bin/env perl
use strict;
##########################################
#
# Description: Append the "message" to 
#              the specified "output.fle".
# Usage: msg.pl "output.fle" "message"
#
##########################################
my($fle);

open($fle, ">>$ARGV[0]") or exit(1);
print $fle ("$ARGV[1]\n");
close $fle;
