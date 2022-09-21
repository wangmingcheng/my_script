use strict;
use warnings;

my @name;
my @text;
$/="\r\n";
while(<>){
	chomp;
	if ($.==1){
		@name=split/\t/,$_;
	}else{
		my @info=split/\t/,$_;
		if (eof){
			for (my $i=1; $i<@info; $i++){
				$text[$i-1].="$info[$i]";
			}
		}else{	
			for (my $i=1; $i<@info; $i++){
				$text[$i-1].="$info[$i],";
			}	
		}
	}
}

for (my $i=0; $i<@text-1; $i++){
	for (my $j=$i+1; $j<@text; $j++){
		open O,">spearman_cor.r";
		print O "a <- c($text[$i])\nb <- c($text[$j])\ncor(a,b,method=\"spearman\")\n";
		my $cor=(split/\s+/,`Rscript spearman_cor.r`)[1];
		print " $name[$i+1]\t$name[$j+1]\t$cor\n";
	}
}
