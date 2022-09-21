use warnings;
use Getopt::Long;
use Bio::SeqIO;

#2019.01.31 by wangmc
#我需要最狂的风，最静的海，还有最遥不可及的你;

my $ver="0.7777777";

my %opts;
GetOptions(\%opts,"g=s","t=s","o=s","h" );

if(!defined($opts{g}) || !defined($opts{t}) || !defined($opts{o}) ||defined($opts{h}))
{
        print <<"       Usage End.";
        Description:
                
                Version: $ver   

        Usage:

                -g           genome file                                <infile>      基因组文件
                -t           motif file                                 <infile>      一行一个motif序列
		-o	     output file                         	<outfile>     还不下雪！！！    
                -h           Help document

       Usage End.

        exit;
}

my $genome_file = $opts{g} ;
my $motif_file = $opts{t} ;
my $outfile = $opts{o} ;

open IN,"$motif_file";
my %fa=&read_fa($genome_file);
open OUT, ">$outfile";
while(<IN>){
	next if /^#/;
	chomp;
	my $motif=$_;
	for my $id (sort keys %fa){
		print OUT "$motif\t$id\t";
		my $index_start=0;
		A:
		my $index_site= index($fa{$id}, $motif, $index_start);
		$index_start = $index_site+length($motif);
		print OUT $index_site+1,"-",$index_site+length($motif),"\t" unless ($index_site == -1);
		goto A unless ($index_site == -1);
		print OUT "\n";
	}
	print OUT "\n";	
}
sub read_fa{
        my ($file) = $_[0]; #基因组文件
#	my $file="SC205.genome.FA";
        my %f;
        my $fa=Bio::SeqIO->new(-file=>$file,-format=>'fasta');
        while(my $seq_obj=$fa->next_seq){
                my $id=$seq_obj->id;
                my $seq=$seq_obj->seq;
                $f{$id}=$seq;
        }
        return %f;
}
