use warnings;
#大道至简; 根据第一列（染色体）分割文件（gff);
my $gff=$ARGV[0] || die "perl $0 file.gff\n";
open IN,"$gff";
while(<IN>){
	chomp;
	next if /#|^\s+/;
	$chr=(split)[0];
	open OUT,">>$gff\.$chr";
	print OUT "$_\n";
	close OUT;
}
