use warnings;
use strict;

#wangmingcheng1992@gmail.com 2018 圣诞节;

#"57个样本，3个相邻的样本分为一组，总共19组: perl generate_WGCNA_sample_cfg.pl 57 3 (注意整除)";

my $sample_num=$ARGV[0];
my $group_capacity=$ARGV[1];
my $group_num=$sample_num/$group_capacity - 1;

print "sample_ID\t";
for (1..$sample_num/$group_capacity){
	chomp $_;
	print "G$_\t";
}
print "\n";

my $nl=0;
for (01..$sample_num){
	chomp $_;
	$nl++;
	my $sym=int(($nl+$group_capacity-1)/$group_capacity);
	#print "$sym";
		if ($_ < 10){
			print "L0$_\t";
		}else{
			print "L$_\t";
		}
	for (2..$sym){
		chomp $_;
		print "0\t"

	}
	print "1\t";
	for ($sym..$group_num){
		chomp $_;
		print "0\t";
	
	}
	print "\n";
}
