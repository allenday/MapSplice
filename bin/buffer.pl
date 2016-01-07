#!/usr/bin/perl
use strict;

open( my $fh, ">/tmp/buffer.out" );
while (my $line = <>){
  warn $line;
  print $fh $line;
}
close( $fh );
