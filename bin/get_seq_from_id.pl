#! /usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use Bio::SeqIO;

my $ver="0.7777777";
my  %opts;
GetOptions(\%opts,"i=s","g=s","h" );

if(!defined($opts{i}) || !defined($opts{g}) || defined($opts{h}))
{
        print <<"       Usage End.";
        Description:
                
                Version: $ver   

        Usage:

                -g           fasta file                                         <infile>     must be given
                -i           id file                                      <infile>     must be given
                -h           Help document
       Usage End.

        exit;
}


my $genome_file = $opts{g} ;
my $id_file = $opts{i} ;

open IN, "$id_file";
my %h;
while(<IN>){
	next if /^#/;
	chomp;
	$h{$_}++;	
}
close IN;
open OUT, ">$id_file.fa";
my $fa=Bio::SeqIO->new(-file=>$genome_file,-format=>'fasta');

while(my $seq_obj=$fa->next_seq){
	my $id=$seq_obj->id;
	my $seq=$seq_obj->seq;
	print OUT ">$id\n$seq\n" if $h{$id};
}
