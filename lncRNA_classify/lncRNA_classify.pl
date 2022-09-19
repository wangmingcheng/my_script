use strict;
use warnings;
use List::Util qw/max min/;

my %ref = &read_ref();
my %novel = &novel_lncRNA();

open O, ">lncRNA_classification.txt";
for my $chr (sort keys %novel){
	my @novel_info = @{$novel{$chr}};
	for (my $i=0; $i<@novel_info; $i++){
		my ($id1, $start1, $end1, $strain1) = @{$novel_info[$i]};
		my $count = 0;
		my $num = 0;
		my $sense_type = "antisense";
		for my $gene (sort keys %{$ref{$chr}}){
			my @ref_info = @{$ref{$chr}{$gene}};			
			for (my $j=0; $j<@ref_info; $j++){
				my ($type, $start2, $end2, $strain2) = @{$ref_info[$j]};
				my $intersect_len = min($end1, $end2) - max($start1, $start2);
				if ($intersect_len > 0){	
					$count++;
					if ($type eq "exon"){
						$num++;
						$sense_type = "sense" if $strain1 eq $strain2;
					}
				}
			}
		}
		if ($count == 0){
			print O "$id1\tlincRNA\n";
		}
		if ($count > 0 and $num == 0){
			print O "$id1\tintronic\n";
		}
		if ($count > 0 and $num > 0){
			print O "$id1\t$sense_type\n";
		}
	}	
}

sub read_ref{
	open I, "ensembl_Sscrofa_v11.1.gtf";
	my %r;
	while(<I>){
		chomp;
		next if /^#|^$/;
		my @a = split/\t/, $_;
		next unless ($a[2] eq "gene" or $a[2] eq "exon");
		my ($gene) = $_ =~ /gene_id "(\S+?)"/;
		push @{$r{$a[0]}{$gene}}, [$a[2], $a[3], $a[4], $a[6]];
	}
	close I;
	return %r;
}

sub novel_lncRNA{
	open IN, "novel_lncRNA.gtf";	
	my %f;
	while(<IN>){
		chomp;
		my @info = split/\t/, $_;
		next unless $info[2] eq "transcript";
		my ($id) = $_ =~ /gene_id "(\S+?)"/;	
		push @{$f{$info[0]}}, [$id, $info[3], $info[4], $info[6]];
	}
	close IN;
	return %f;
}
