#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
use List::Util qw/max min sum maxstr minstr shuffle/;
my $ver="1.7";

my %opts;
GetOptions(\%opts,"i=s","r=s","o=s","w=s","b=s","h" );

#&help()if(defined $opts{h});
if(!defined($opts{i}) || !defined($opts{r}) || !defined($opts{o}) || defined($opts{h}))
{
	print <<"	Usage End.";
	Description:
		
		Version: $ver	

	Usage:

		-i           methy site info file                          <infile>     must be given
		-r           region file                                   <infile>     must be given
		-o           output file                                   <outfile>    must be given
		-w           window length                                 [int]        optional [2000] bp
		-b           bin length                                    [int]        optional [50] bp
		-h           Help document

	Usage End.

	exit;
}

my $methyfile = $opts{i} ;
my $regfile = $opts{r} ;
my $outfile = $opts{o} ;
my $window = defined $opts{w} ? $opts{w} : 2000 ;
my $bin = defined $opts{b} ? $opts{b} : 50 ;

my %methy=&read_methy_file($methyfile);
my %region=&read_region_file($regfile,$window,$bin);

open (OUT, ">$outfile") || die "cannot open $outfile !\n";

#my %result;
foreach my $chr (sort keys %region){
	for my $name(sort keys %{$region{$chr}}){
		print OUT "$name\t";
		my @array= sort { $a->[0] <=> $b->[0] || $a->[1] <=> $b->[1] } @{$region{$chr}{$name}};
#		my %result;
		for(my $i=0;$i<scalar(@array);$i++){
			my ($start,$end,$index)= @{$array[$i]};
#			print OUT "$index\t";
			my @pos=sort {$a <=> $b} keys %{$methy{$chr}};
			my $site_num = 0;
			for(my $j=0;$j<scalar(@pos);$j++){
				if( $pos[$j] > $start and $pos[$j]<= $end ){
					$site_num += 1;
				}
			}
			print OUT "$site_num\t";				
		}									
		print OUT "\n";
	}
}
=c
foreach my $key (sort {$a<=>$b} keys %result){
	print OUT "$key\t$result{$key}\n";
}

close OUT;
=cut
#---------------------------------------------------------------------------------------------------------
#读入组蛋白文件
sub read_methy_file()
{
	my ($file) = $_[0] ;
	my %ahmethy;
	open (IN, $file) || die "$file, $!\n" ;
	while(<IN>){
		chomp ;
		next if /#|^\s+/ ;
		my ($chr, $start, $end) = (split/\t/)[0,1,2] ;
		for my $pos($start..$end){
#		$ahmethy{$chr}{$pos} = $frac;
		$ahmethy{$chr}{$pos} = 1 ;
		}
	}
	close(IN);
	return %ahmethy; #存放4mc甲基化的位点和染色体信息
} 
#组蛋白文件
sub read_region_file()
{
	my ($regfile,$winds,$bins) = @_ ;
	my %region;
	open (IN, $regfile) || die "cannot open $regfile, $! \n";
	while(<IN>){
		chomp ;
		next if (/#|^\s+/);
		my @info=split/\t/;
		my $start=$info[4]-($winds);#起始的位置，真实坐标
		my $end=$info[4]+($winds);
		#$start=0 if ($start<0);
	#	$info[0]="chr".$info[0];#4mc文件中为chr1, 组蛋白文件中为1;
		my $bin_num=2*$winds/$bins;
		for(my $i=0;$i<$bin_num;$i++){
				my $index_start=$start+$bins*$i;
				my $index_end=$index_start+$bin;
				last if ($index_end>$end);
				my $index=$index_start-$info[4];
				push @{$region{$info[0]}{$info[-1]}}, [$index_start,$index_end,$index];
		}
	}
	return %region;
}
