use strict;
use warnings;
use Getopt::Long;

#wangmc 20190214;
#橘子辉煌，今天的雪本应使人心情舒畅;

my $ver="0.7777777";

my %opts;
GetOptions(\%opts,"p=s","o=s","h" );

if(!defined($opts{p}) || !defined($opts{o}) ||defined($opts{h}))
{
        print <<"       Usage End.";
        Description:
                
                Version: $ver   

        Usage:

                -p           ensemble pepfile                           <infile>      蛋白文件（fa）
                -o           output file                                <outfile>     还不下雪！！！    
                -h           Help document

       Usage End.

        exit;
}
my $pep=$opts{p};
my $out=$opts{o};

my %pep_fa=&read_fa($pep);
open OUT,">$out";

foreach my $gene (sort keys %pep_fa){
	my @temp=(sort{$a <=> $b} keys %{$pep_fa{$gene}});
	my $len=pop @temp;	
	print OUT ">$gene\n$pep_fa{$gene}{$len}\n";
}

sub read_fa{
	my ($in)=$_[0];
	open IN, "$in";
	$/ = "\>";
	my %h;
	while(<IN>){
		chomp;
		my @line = split("\n", $_);
		next if @line == 0;
		my $identifier = shift @line;
		my $seq = join "", @line;
		my $peplen = length($seq);
		$identifier =~ /^(\S+).*gene:(\S+)/;
		my ($pepid, $geneid) = ($1, $2);
		$h{$geneid}{$peplen} = $seq;
	}
	close IN;
	$/ = "\n";
	return %h;
}
