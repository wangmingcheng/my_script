#!usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
  
#20190304 by wangmc;
#青青子佩，悠悠我思;

my %opts;
GetOptions(\%opts,"i=s","o=s","w=s","h");
if(!defined($opts{i}) || !defined($opts{o}) || defined($opts{h}))
{
	print <<"	Usage End.";
	
	Description: Statistic the GC content of fasta file
	Usage:
	 -i, --infile    input fasta file
         -o, --outfile   output file
         -w, --bin       Window size(default 1000)
         -h, --help      Display this help message
	
	Usage End.
	
	exit;

}
 
## parse options from @ARG
my $infile=$opts{i};
my $outfile=$opts{o};
my $bin=defined $opts{w}?$opts{w}:1000;

open IN,"$infile" || die"can't open $infile";
open OUT,">$outfile";
print OUT "#Chr\tStart\tEnd\tGC_num\n";
$/=">";<IN>;$/="\n";
while(<IN>){
          my $chr=$1 if /^(\S+)/;
          $/=">";
          chomp(my $seq=<IN>);
          $/="\n";
          $seq=~s/\n+//g;
          my $len=length$seq;
          for (my $i=0;$i<$len/$bin;$i++){
                  my $loc=$i*$bin;
                  my $sub_fa=uc(substr($seq,$loc,$bin));
                  my $GC=$sub_fa=~tr/GC//;
                  my $start=$i*$bin+1;
                  my $end=($i+1)*$bin;
                  $end=$len if($end>$len || $len < $bin);
                  my $out=join "\t",$chr,$start,$end,$GC;
                  print OUT ($out,"\n");
 
          }
}
 close IN;
