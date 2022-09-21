#! usr/bin/perl 
use strict;
use warnings;
use Getopt::Long;

#孤独乃本质，自由非追求；To be yourself，accept yourself and don't lost yourself
#wangmc 20190305,天蓝不见白云；
my $ver=0.7777777; 

my %opts;
GetOptions(\%opts, "i=s", "o=s", "w=s", "h");
if(!defined($opts{i}) || !defined($opts{o}) || defined($opts{h}))
{
	print <<"	Usage End.";
	Description:
		Version:$ver;
	
	Usage:

	-i	fasta file		<input_file>	forced
	-o	name of output file 	<output_file>	foeced
	-w	line width		<width>		optional
	
	Usage End.
	exit;
}	
my $infile=$opts{i};
my $outfile=$opts{o};
my $width=defined($opts{w})?$opts{w}:200;

open IN,"<$infile"||die"can't open $infile";
open OUT,">$outfile";


$/=">";<IN>;$/="\n";
while(<IN>){
    my $chr=$1 if /^(\S+)/;
    $/=">";
    chomp(my $seq=<IN>);
    $/="\n";
    $seq=~s/\n+//g;
    print OUT ">$chr\n";
    my $start=0;
    my $len=length($seq);
    while($start+$width<$len){
    $b=substr($seq,$start,$width);
    print OUT "$b\n";
    $start=$start+$width;}
    while($start+$width>=$len){
    $b=substr($seq,$start,$width);
    print OUT "$b\n";
    last;}
}
