#!/usr/bin/perl
use strict;
use Data::Dumper qw(Dumper);
use File::Glob;
use File::Temp qw(tempfile);
use JSON qw(decode_json);

my $template = "@%s/%d\n%s\n+%s/%d\n%s\n";

#my $s = shift @ARGV;
my $s = "['/mapr/ADPPOC/user/aday/src/MapSplice/bin/mapsplice_multi_thread', '-q', '--min_len', '25', '--seg_len', '25', '--min_intron', '50', '--max_intron_single', '300000', '--max_intron_double', '300000', '-v', '1', '--max_double_splice_mis', '2', '--max_single_splice_mis', '1', '--max_append_mis', '3', '--max_ins', '6', '--max_del', '6', '-k', '40', '-m', '40', '-p', '1', '--chrom_tab', '/mapr/ADPPOC/user/aday/data/bms/small.mapsplice/tmp/chrom_sizes', '--ref_seq_path', '/mapr/ADPPOC/user/aday/data/bms/hg19ERCC/chromosomes/', '--mapsplice_out', '/tmp/tmph49qL5.sam', '--check_read', '/mapr/ADPPOC/user/aday/data/bms/small.mapsplice/logs/check_reads_format.log_599613', '--qual-scale', 'phred33', '--splice_only', '--min_map_len', '0', '/mapr/ADPPOC/user/aday/data/bms/hg19ERCC/bowtie_index/hg19ERCC', '-1', '/tmp/tmpGjpswH_1.fastq', '-2', '/tmp/tmpjY9owK_2.fastq', '/mapr/ADPPOC/user/aday/data/bms/small.mapsplice/tmp/original/debug_info_389338']";
$s =~ s/'/"/g;
warn $s;

my $j = decode_json( $s );

warn Dumper $j;

my $cmd = join " ", @$j;

warn $cmd;

my $fq1;
my $fq2;
my $out;


for ( my $i = 0 ; $i < scalar( @$j ) ; $i++ ) {
  if ( $j->[$i] eq '-1' ) {
    $fq1 = $j->[$i+1];
  }
  elsif ( $j->[$i] eq '-2' ) {
    $fq2 = $j->[$i+1];
  }
  elsif ( $j->[$i] eq '--mapsplice_out' ) {
    $out = $j->[$i+1];
  }
}

open( my $fh1, ">$fq1" );
open( my $fh2, ">$fq2" );


#my ($fh1, $fq1) = tempfile( "multithread_wrapper_XXXXX", SUFFIX => '_1.fq', UNLINK => 1 );
#my ($fh2, $fq2) = tempfile( "multithread_wrapper_XXXXX", SUFFIX => '_2.fq', UNLINK => 1 );

print "AAA\n";

while (my $line = <>){
  chomp $line;
  $line =~ s/^\(/[/;
  $line =~ s/\)$/]/;
  my $pair = decode_json( $line ) or die $line;

  my $read1 = sprintf( $template,
    $pair->[0]->{'readName'},
    1,
    $pair->[0]->{'sequence'},
    $pair->[0]->{'readName'},
    1,
    $pair->[0]->{'qual'},
  );

  my $read2 = sprintf( $template,
    $pair->[1]->{'readName'},
    2,
    $pair->[1]->{'sequence'},
    $pair->[1]->{'readName'},
    2,
    $pair->[1]->{'qual'},
  );

  print $fh1 $read1;
  print $fh2 $read2;
}

print "BBB\n";

close( $fh1 );
close( $fh2 );

#open( SAM, "/mapr/ADPPOC/user/aday/src/bowtie-1.1.2/bowtie /mapr/ADPPOC/user/aday/data/bms/hg19ERCC/bowtie_index/hg19ERCC -1 $fq1 -2 $fq2 |" );
system( $cmd );
foreach my $f ( glob "$out*" ) {
  open( SAM, $f );
  while ( my $line = <SAM> ) {
    warn $line;
    print $line;
  }
  close( SAM );
}

unlink( $fq1 );
unlink( $fq2 );
