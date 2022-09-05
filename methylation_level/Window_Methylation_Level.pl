use strict;
use Getopt::Long;
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
use List::Util qw/max min sum maxstr minstr shuffle/;
my $ver="1.0";

my %opts;
GetOptions(\%opts,"i=s","r=s","o=s","b=s","h" );

#&help()if(defined $opts{h});
if(!defined($opts{i}) || !defined($opts{r}) || !defined($opts{o}) || defined($opts{h})){
	print <<"	Usage End.";
	Description:
		
		Version: $ver	

	Usage:

		-i           methy  file                          	   <infile>     must be given
		-r           chr    file                                   <infile>     must be given
		-o           output file                                   <outfile>    must be given
		-b           bin length                                    [int]        optional [100000] bp
		-h           Help document

	Usage End.

	exit;
}

my $methyfile = $opts{i} ;
my $regfile = $opts{r} ;
my $outfile = $opts{o} ;
my $bin = defined $opts{b} ? $opts{b} : 100000 ;

my %methy = &read_methy_file($methyfile);
my %region = &read_region_file($regfile,$bin);

open (OUT, ">$outfile") || die "cannot open $outfile !\n";
print OUT "Chr\tStart\tEnd\tSite_count\tMethyLevel\tmC_count\tumC_count\n";
foreach my $chr (sort keys %region){
	my @reg = sort {$a -> [1] <=> $b -> [1]} @{$region{$chr}};
	my @methy = sort @{$methy{$chr}} if $methy{$chr};
		
	for(my $i=0; $i < @reg; $i++){
		my ($start, $end)= @{$reg[$i]};
		my $mC_num = 0;
		my $umC_num = 0;
		my $site_num = 0;
		for(my $j=0; $j<@methy; $j++){
			my ($pos, $mC, $umC) = @{$methy[$j]};
			if( $pos >= $start and $pos < $end ){
				$mC_num += $mC;
				$umC_num += $umC;
				$site_num ++;
			}
		}
		my $MethyLevel_raw = $mC_num ? $mC_num / ($mC_num + $umC_num) : 0;
		my $MethyLevel = sprintf("%.2f", $MethyLevel_raw);
		print OUT "$chr\t$start\t$end\t$site_num\t$MethyLevel\t$mC_num\t$umC_num\n";
	}						
}

#---------------------------------------------------------------------------------------------------------
=head1
Chr     Position        Strand  MethyLevel      mC_count        umC_count       count   pvalue  fdr
chr1    3000828 -       0.9     9       1       10      1.40561085254702e-23    8.79661338348473e-23
chr1    3001277 +       1       5       0       5       5.61436199405266e-14    8.27155894844629e-14
=cut
sub read_methy_file(){
	my ($file) = $_[0] ;
	my %methy;
	#open (IN, "gzip -dc $file|") || die "$file, $!\n" ;
	open (IN, $file) || die "$file, $!\n" ;
	while(<IN>){
		chomp ;
		next if /#|^\s+/ ;
		my ($chr, $pos, $strain, $level, $mC, $umC, $total_count, $pval, $fdr) = split /\t/;
		push @{$methy{$chr}}, [$pos, $mC, $umC];
	}
	close IN;
	return %methy; 
}
#---------------------------------------------------------------------------------------------------------- 
=head2
#CHR	LEN	other
chr1    195471971       6       60      61
chr2    182113224       198729850       60      61
chr3    160039680       383878301       60      61
=cut
#----------------------------------------------------------------------------------------------------------
sub read_region_file(){
	my ($regfile,$bins) = @_ ;
	my %region;
	open (IN, $regfile) || die "cannot open $regfile, $! \n";
	while(<IN>){
		chomp ;
		next if (/#|^$/);
		my @info = split/\t/;   
		my $bin_num = $info[1] / $bins;
		for(my $i = 0; $i<$bin_num; $i++){
			my $index_start = 0 + $bins*$i;
			my $index_end = $index_start+$bin;
			$index_end = $info[1] if ($index_end > $info[1]);
			push @{$region{$info[0]}}, [$index_start, $index_end];
		}
	}
	return %region;
}
#------------------------------------------------------------------------------------------------------------
