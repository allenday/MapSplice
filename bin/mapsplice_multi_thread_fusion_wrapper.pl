#!/usr/bin/perl
use strict;
use File::Temp qw();

my $chrom_tab = shift @ARGV or die usage();    #small3.mapsplice/tmp/chrom_sizes
my $ref_seq_path = shift @ARGV or die usage(); #hg19ERCC/chromosomes/
my $check_read = shift @ARGV or die usage();   #small3.mapsplice/logs/check_reads_format.log

my ($sam_fh, $sam_filename) = File::Temp::tempfile( "MapSplice_XXXXXXXX", SUFFIX => '.dat');
close( $sam_fh );
my ($fusion_fh, $fusion_filename) = File::Temp::tempfile( "MapSplice_fusion_XXXXXXXX", SUFFIX => '.dat');
close( $fusion_fh );

#TODO: do we need to handle mapsplice_out here, or is it the same as the call without --fusion?
open( SUBPROC, "| /mapr/ADPPOC/user/aday/src/MapSplice/bin/mapsplice_multi_thread -q --min_len 25 --seg_len 25 --min_intron 50 --max_intron_single 300000 --max_intron_double 300000 -v 1 --max_double_splice_mis 2 --max_single_splice_mis 1 --max_append_mis 3 --max_ins 6 --max_del 6 -k 40 -m 40 -p 8 --chrom_tab $chrom_tab --ref_seq_path $ref_seq_path --mapsplice_out $sam_filename --check_read $check_read --optimize_repeats --fusion $fusion_filename --min_fusion_distance 10000" );

while ( my $line = <> ) {
  print SUBPROC $line;
}

close( SUBPROC );

open( RESULT, $fusion_filename ) or die $!;

while ( my $line = <RESULT> ) {
  print $line;
}

close( RESULT );

sub usage {
  print "Usage: $0 <chrom_tab> <ref_seq_path> <check_read>\n";
  exit( 1 );
}