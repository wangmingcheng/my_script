use strict;
use warnings;

my @in = <J*txt>; 
#存全部样本的所有位置信息；
my %all;
my %sample;
for my $in (@in){
	open IN, "$in";
#	our %sample;
	while(<IN>){
		next if /unmethylated/;
		chomp;
		my ($chr, $pos, $type, $methy, $unmethy)=(split)[0, 1, 5, 3, 4];
		my $methylevel=$methy / ($methy + $unmethy);
		$all{$chr}{$pos}=$type;
		${$sample{$in}}{$chr}{$pos}=$methylevel;
	}
	close IN;
}

for my $k1 (sort keys %all){
	for my $k2 (sort keys %{$all{$k1}}){
		for my $samp (sort keys %sample){
			open OUT,">>$samp.tt";		
			my %f = %{$sample{$samp}};
			if ($f{$k1}{$k2}){
				print OUT "$k1\t$k2\t$f{$k1}{$k2}\t$all{$k1}{$k2}\n";
			}else{
				print OUT "$k1\t$k2\t0\t$all{$k1}{$k2}\n";
			}
		}
	}
}
