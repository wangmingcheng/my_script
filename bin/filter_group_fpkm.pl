use strict;
use warnings;
use List::Util qw/max min/;

=cut
57 samples divided into 19 groups
Retain the line: at least 1 group whose average fpkm >=0.1
=cut

while (<>){
	chomp;
	print "$_\n" if /^#/;
	next if /^#/;
	my @gene_fpkm=split;
	shift @gene_fpkm;
	
	my ($i, $aver)=(0, 0);
	my @group;	
	for my $fpkm(@gene_fpkm){		
		chomp $fpkm;
		$i++ if (defined $fpkm);
		$aver+=$fpkm;
		push @group, $aver if $i == 3;
	#	print "$aver\t" if $i == 3;
		$aver=0,$i=0 if $i == 3;
	}
	my $max = max @group;
	print "$_\n" if $max >= 0.3;
}
