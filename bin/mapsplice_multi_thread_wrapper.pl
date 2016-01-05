#!/usr/bin/perl
use strict;
use File::Temp qw();

my $chrom_tab = shift @ARGV or die usage();    #small3.mapsplice/tmp/chrom_sizes
my $ref_seq_path = shift @ARGV or die usage(); #hg19ERCC/chromosomes/
my $check_read = shift @ARGV or die usage();   #small3.mapsplice/logs/check_reads_format.log
my $bowtie_index = shift @ARGV or die usage(); #hg19ERCC/bowtie_index/hg19ERCC
my $debug_log = shift @ARGV or die usage();    #small2.mapsplice/tmp/original/debug_info

my ($sam_fh, $sam_filename) = File::Temp::tempfile( "MapSplice_x_XXXXXXXX", SUFFIX => '.dat');
close( $sam_fh );

my $cmd = join(' ', '/mapr/ADPPOC/user/aday/src/MapSplice/bin/mapsplice_multi_thread', '-q', '--min_len', '25', '--seg_len', '25', '--min_intron', '50', '--max_intron_single', '300000', '--max_intron_double', '300000', '-v', '1', '--max_double_splice_mis', '2', '--max_single_splice_mis', '1', '--max_append_mis', '3', '--max_ins', '6', '--max_del', '6', '-k', '40', '-m', '40', '-p', '8', '--chrom_tab', $chrom_tab, '--ref_seq_path', $ref_seq_path, '--mapsplice_out', $sam_filename, '--check_read', $check_read, '--qual-scale', 'phred33', '--splice_only', '--min_map_len', '0', $bowtie_index, '-1', 'small_1.prep.fastq', '-2', 'small_2.prep.fastq', $debug_log);

open( SUBPROC, "| $cmd" );

open( SUBPROC, "| /mapr/ADPPOC/user/aday/src/MapSplice/bin/mapsplice_multi_thread -q --min_len 25 --seg_len 25 --min_intron 50 --max_intron_single 300000 --max_intron_double 300000 -v 1 --max_double_splice_mis 2 --max_single_splice_mis 1 --max_append_mis 3 --max_ins 6 --max_del 6 -k 40 -m 40 -p 1 --chrom_tab $chrom_tab --ref_seq_path $ref_seq_path --mapsplice_out $sam_filename --check_read $check_read" );

while ( my $line = <> ) {
  print SUBPROC $line;
}

close( SUBPROC );

open( RESULT, $sam_filename ) or die $!;

while ( my $line = <RESULT> ) {
  print $line;
}

close( RESULT );

sub usage {
  print "Usage: $0 <chrom_tab> <ref_seq_path> <check_read> <bowtie_index> <debug_log>\n";
  exit( 1 );
}
