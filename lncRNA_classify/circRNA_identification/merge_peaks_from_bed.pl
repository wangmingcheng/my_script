use strict;
use warnings;
use List::Util qw/max min/;

my %bed1 = &read_bed($ARGV[0]);
my %bed2 = &read_circ($ARGV[1]);

for my $chr (sort keys %bed1){
	my @bed1 = @{$bed1{$chr}};
	my @bed2 = @{$bed2{$chr}} if $bed2{$chr};	
	for (my $i = 0; $i < @bed1; $i++){
		my ($s1, $e1, $name) = @{$bed1[$i]};
		#print "$s1\t$e1\t$name\n";
		for (my $j = 0; $j < @bed2; $j++){
			my ($s2, $e2, $id) = @{$bed2[$j]};
			my $dis = abs($s1-$s2) + abs($e1-$e2);
			my $inter_len = min($e1, $e2) - max ($s1, $s2) + 1;
			my $p = sprintf("%.2f", $inter_len/min($e1-$s1, $e2-$s2));
			print "$chr\t$name\t$s1\t$e1\t$id\t$s2\t$e2\t$dis\t$p\n" if $inter_len >= 0;
		}
	}
}
sub read_bed(){
	my %f;
	my ($bed) = @_;
	open IN,"$bed";
	while(<IN>){
		chomp;
		my ($chr, $start, $end, $name) = (split/\t/,$_)[0, 1, 2, 4];
		push @{$f{$chr}}, [$start, $end, $name];
	}
	return %f;
	close IN;
}

sub read_circ(){
	my %f;
	my ($bed) = @_;
	open IN,"$bed";
	while(<IN>){
		next if $.==1;
		chomp;
		my ($id, $chr, $start, $end) = (split/\t/,$_)[0, 1, 2, 3];
		push @{$f{$chr}}, [$start, $end, $id];
	}
	return %f;
	close IN;
}
