use strict;
use warnings;
use File::Basename qw/basename dirname/;

my $indir = shift;
my @in = `ls $indir/*stat.gz`;
my %f;
for my $in (@in){
	chomp $in;
	open IN,"gzip -dc $in|"; 

	my ($sample, $meth, $type) = (split/\_|\./, basename $in)[0, 1, 2];
	while(<IN>){
		next if $.==1;
		chomp;
		my @a = split;
		for (my $i=6; $i<@a; $i++){
			push @{$f{$sample}{$meth}{$type}{$i}}, $a[$i];
		}
	}
	close IN;
}

for my $samp (sort keys %f){
	for my $met (sort keys %{$f{$samp}}){
		my $j = 1;
		for my $type (sort keys %{$f{$samp}{$met}}){
			for my $bin (sort {$a <=> $b} keys %{$f{$samp}{$met}{$type}}){
				$j = sprintf("%03d",$j);
				print "$samp\t$met\t$type\t$j\t", average(@{$f{$samp}{$met}{$type}{$bin}}),"\n";
				$j++;
			}
		}
	}
}
sub average{
	my $aver = 0;
	map {$aver += $_ unless $_ eq "nan"} @_;
 	$aver /= ($#_ + 1 );
}
