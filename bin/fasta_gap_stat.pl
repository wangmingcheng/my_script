#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;

#不求不妄，苦乐自当 wangmc 2019 秋
my $ver="0.7777777";
my %opts;
GetOptions(\%opts,"i=s","o=s","h" );

if(!defined($opts{i}) || !defined($opts{o}) || defined($opts{h})){
        print <<"       Usage End.";
       	
	Description:
		Stat the gap(N) length
	Version: $ver   
        Usage:
                -i           fasta file                                         <infile>     must be given
                -o           output file                                        <infile>     must be given
                -h           Help document
       
       Usage End.
        exit;
}

my $infile = $opts{i} ;
my $outfile = $opts{o} ;

# Start Time
my $Time_Start;
$Time_Start = &formate_datetime(localtime(time()));
print "\nStart Time :[$Time_Start]\n\n";
#
open IN,$infile or die $!;
open OUT,">$outfile" or die $!;
print OUT "#chr\tgap_start\tgap_end\tgap_len\n";

$/ = ">";
while (<IN>){
	chomp;
	next if ($_ =~ /^\s*$/);
	my @scf_seq = split /\n/,$_;
	my $scf_title = shift @scf_seq;
	my $scf_seq = join "",@scf_seq;
	$scf_seq = uc($scf_seq);
	$scf_seq =~ s/^N+//g;
	my $leng=length($scf_seq);
	my $gapLeft=0;
	while($scf_seq=~/(N+)/ig){
		my $lenN=length($1);
		my $gapRight=pos($scf_seq) + 1;
		$gapLeft = $gapRight - $lenN;
		print OUT "$scf_title\t$gapLeft\t$gapRight\t$lenN\n";
	}
}
$/ = "\n";
close IN;
close OUT;

# End Time
my $Time_End;
$Time_End = &formate_datetime(localtime(time()));
print "\nEnd Time :[$Time_End]\n\n";

# formate_datetime
sub formate_datetime(){
	my($sec, $min, $hour, $day, $mon, $year, $wday, $yday, $isdst) = @_;
	$wday = $yday = $isdst = 0;
	sprintf("%4d-%02d-%02d %02d:%02d:%02d", $year+1900, $mon+1, $day, $hour, $min, $sec);
}
