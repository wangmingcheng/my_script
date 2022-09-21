use strict;
use warnings;
use Bio::SeqIO;
use Getopt::Long;

#20190709 by wangmc

my $ver = 0.7777777;
my  %opts;
GetOptions(\%opts, "m=s", "r=s", "t=s", "h" );

if(!defined($opts{m}) || !defined($opts{r}) || defined($opts{h}))
{
        print <<"	Usage End.";
        Description:

                Version: $ver

        Usage:

                -m           muscle.config                                         <infile>     must be given
                -r           genefamily 	                                   <infile>     the same as Result.txt format
		-t	     seqtype					           <optional>	default pep(another choice cds)
                -h           Help document
	Usage End.

        exit;
}

#my $Result_txt = shift;
my $type = defined $opts{t}? $opts{t}: "pep";
my $muscle_config = $opts{m};
my $Result_txt = $opts{r};

my %seq_info = &config_parse($muscle_config);
#my $Result_txt = "Result.txt";
open IN, $Result_txt or die $!;
while (<IN>){
	chomp;
	my ($genefamily_info, $gene_species_info)=split/\t/,$_;
	my ($genefamily)=$genefamily_info=~/(GF_\d+)/;
	open OUT,">>$genefamily.fa";
	for my $gene_species (split/\s+/, $gene_species_info){
		my ($gene, $species)=$gene_species=~/(\S+?)\((\S+)\)/;
		print OUT ">$gene_species\n$seq_info{$species}{$type}{$gene}\n";
	}
}

#muscle_config
sub config_parse(){
         my $lib = shift;
#        my $lib = "muscle.config";
         my %config;
         open(my $LIB, '<', $lib) || die($!);
         local $/="\n\n";
         while(<$LIB>){
                 chomp;
                 my $key;
                 for my $line (split(/\n/, $_)){
                         next if($line =~ /^\#/);
                         if($line=~/^key/){
                                 $key = (split(/\s+/, $line))[1];
                         }else{
                                my ($tag, $value) = split(/\s+/, $line);
				my $fa=Bio::SeqIO->new(-file=>$value,-format=>'fasta');
				while(my $seq_obj=$fa->next_seq){
    					my $id=$seq_obj->id;
        				my $seq=$seq_obj->seq;
                                	$config{$key}->{$tag}{$id} = $seq;
				}
			}
		}
	}
         local $/="\n";
         close($LIB);
         return(%config);
}
