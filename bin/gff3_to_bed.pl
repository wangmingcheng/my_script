use strict;
use warnings;

my $usage="$0 <gff3> <bedf>
the bedf is used for the geneBody_coverage

\n";

die $usage if @ARGV<2;

my($gff,$bedf)=@ARGV;

my(@info,%gff,@gids,$id);

open I,$gff;
while(<I>){
	chomp;
	@info=split /\t/;
	($id)=$info[8]=~/ID=([^;]+)/;
	if($info[2] eq "mRNA"){
		push @gids,$id;
	}
	push @{$gff{$id}},$_;
}
close I;

open O,">",$bedf;
foreach my $id (@gids){
	my @cdss=@{$gff{$id}};
	my @cdssort=map{$_->[1]}sort{$a->[0] <=> $b->[0]}map{[(split /\t/)[3],$_]}@cdss[1..$#cdss];
	my @line1=split /\t/,$cdss[0];
	my @line2=split /\t/,$cdssort[0];
	my (@num,@cumNum);
	my $tot;
	my $cdsNum=@cdssort;
	foreach my $id2 (@cdssort){
		my @info2=split /\t/,$id2;
		my $n1=$info2[4] - $info2[3] +1;
		$tot = $info2[3] - $line2[3];
		push @num,$n1;
		push @cumNum,$tot;
	}
	print O "$line1[0]\t".($line1[3]-1)."\t$line1[4]\t$id\t0\t$line1[6]\t".($line1[3]-1)."\t$line1[4]\t0\t$cdsNum\t";
	print O join(",",@num),",\t",join(",",@cumNum),",\n";
}
close O;

