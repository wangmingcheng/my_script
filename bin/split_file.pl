#!/usr/bin/perl -w
use warnings;
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
use Getopt::Long;

my $ver="1.0";

my %opts;
GetOptions (\%opts,"i=s","n=s","h");

if(!defined($opts{i}) ||  defined($opts{h}))
{
	print <<"	Usage End.";
        Description:
                
                Version: $ver

	Usage:

                -i           input file           		           <infile>     must be given
                -n           number parts for split                        <infile>     optional [10]
                -h           Help document

	Usage End.
	exit;
}

#$0=~s/.*\/(.+)/$1/;
$| =1;
$datafile=$opts{i};
$opt_parts=defined $opts{n} ? $opts{n} : 10;

open(IN,$datafile) || die $!;
my $total=0;
while(<IN>){ $total++;}
my $part=1;
my $lines=0;

$partfile=$datafile . $part;

open(PART, ">$partfile");

while(<IN>){
	$partfile=$datafile . $part;

	$dataline=$_;
	if($lines < int($total/$opt_parts) || $part==$opt_parts){
		print PART $dataline;
		$lines++;
	}else{
		$part++;
		$lines=0;
		$partfile=$datafile . $part;
                print PART $dataline;
                $lines++;
	}}
