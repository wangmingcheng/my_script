use warnings;
use strict;
use Getopt::Long;

#by wangnc 2019二月的最后一天;
#一川烟草，满城风絮，梅子黄时雨;
my $ver=0.77777;

my %opts;
GetOptions(\%opts,"i=s","o=s","h" );

if(!defined($opts{i}) || !defined($opts{o}) || defined($opts{h}))
{
        print <<"       Usage End.";
        Description:
                
                Version: $ver

        Usage:

                -i           scaffold fasta file           <infile>     must be given
                -o           result file                   <outfile>    must be given
                -h           Help document

       Usage End.

        exit;
}

my $infile  = $opts{i} ;
my $outfile = $opts{o} ;

open IN,"$infile";
open OUT,">$outfile";
$/="\>";
while(<IN>){
	chomp;
	next if (/^\s*$/);
	my ($head, $seq)=split /\n/, $_, 2;
	$seq=~s/\n//g;
	my $id=(split/\s+/,$head)[0];
	my @seq=split/N+|n+/,$seq;
	my $num=1;
	for (@seq){
		print OUT ">$id\_$num\n$_\n";
		$num++;
	}
}
$/="\n";
close IN;

=c
	while($seq=~/([^N])N+([^N])/g){
		my $pos=pos($seq);
		my $n_len=length($1);
		my $right_loc=$2;
		print "$left_loc-$right_loc\t";
		$left_loc=$pos;
		#my $subseq=substr
	}
	print "\n";
}
$/="\n";
