use strict;
use warnings;

use File::Basename qw/basename dirname/;

my $tool = "/Data2/wangmc/software/gatk-4.2.5.0/gatk CollectInsertSizeMetrics";

#my @bam = </Data4/nbCloud/public/AllProject/\@2022-03/project_622f05b52b0c5f7314dff25c/task_622f05fa2b0c5f7314dff2e6/*unique.bam>;
my @bam = </Data4/nbCloud/public/AllProject/\@2022-04/project_62510c32626ee6bbb7a64ef3/task_6255c44cfd302f9978f97b39/*.bam>;

for my $bam (@bam){
	chomp $bam;
	my $name = (split/\./, basename $bam)[0];
	#print "$name\n";
	print "$tool --Histogram_FILE $name\_insert_size.pdf --INPUT $bam --OUTPUT $name\_insert_size.txt\n";
}
