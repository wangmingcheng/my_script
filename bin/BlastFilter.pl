#!/share/nas2/genome/bin/perl
#===============================================================================
#         FILE: BlastFilter.pl
#  DESCRIPTION: 
#
#       AUTHOR: juyh (juyou3hui@gmail.com)
#      CREATED: 2016年01月11日 00时52分17秒
#===============================================================================
use strict;
use warnings;
use Getopt::Long;
use File::Basename qw(basename dirname fileparse); 
use Data::Dumper;
use Pod::Text;
use FEATURE;
use BLAST;
use Cwd qw(abs_path getcwd);
my $bin = dirname(abs_path($0));
my ($blast_f, $key, $ratio, $order, $indenty, $len, $score, $len_ratio, $len_file);
GetOptions(
            'b=s'=>\$blast_f,  
            'k=s'=>\$key,
            'r=s'=>\$ratio,
            'o=s'=>\$order,
            'i=s'=>\$indenty,
            'l=s'=>\$len,
            's=s'=>\$score,
            'lr=s'=>\$len_ratio,
            'lf=s'=>\$len_file,
          )|| &help;

&help() unless $blast_f;
sub help
{
    my $useage=<<USE;
    perl $0 -b <blast_f>  -k <key> -r <ratio> [-l|i|o|s|lr|lf]
USE
    print $useage;
    exit;
}

$len_ratio ||= 0.9;
my $blast = ReadBlast($blast_f, $len, $indenty, $score);
my ($pep_len, $max_sc) = SimpifyBlast($blast);

my %q = map { $_ => 1} keys %$blast;

RemoveEmpty($blast);
ReverseBlast($blast);

FilterBlast($blast, $max_sc,$ratio);
RemoveEmpty($blast);

if($len_file){
    my $len = readLenflie($len_file);
    for my $q (keys %$blast){
        for my $t (keys %{$blast->{$q}}){
            my $match_len = $blast->{$q}{$t}{feat}[1];
            my $seq_len = $len->{$q} ? $len->{$q} : $len->{$t};
            if ($len<$seq_len*$len_ratio){
                delete $blast->{$q}{$t};
                delete $blast->{$t}{$q};
            }
        }
    }
}
RemoveEmpty($blast);

WriteBlast($blast, "$key.blast", \%q);

sub readLenflie
{
    my %len;
    open my $IN, shift;
    while(<$IN>){
        chomp;
        my ($query, $len) = split;
        $len{$query} = $len ;
    }
    return \%len;
}
