#!/usr/bin/perl
# Writer:         Fanr <fanr@biomarker.com.cn>
# Program Date:   2016
# Modifier:       Fanr <fanr@biomarker.com.cn>
use strict;
use warnings;
use Getopt::Long;
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
use newPerlBase;

#############################################################################

my $Function = "...";
my $Ver = "1.0";
my $Ver_describe = "...";

# GetOptions
my ($infile,$outfile);
GetOptions(
			"i:s" => \$infile,
			"o:s" => \$outfile,
			"h" => \&USAGE
) or &USAGE;
&USAGE if (!defined $infile || !defined $outfile);
# Start Time
my $Time_Start;
$Time_Start = &formate_datetime(localtime(time()));
print "\nStart Time :[$Time_Start]\n\n";
######################################################################################
my @data;
my %hash2;
my %hash1;
open(LIST,"$infile") || die $!;
open(OUT ,">$outfile")|| die  $!;

while(<LIST>){ 
        chomp; 
	next if(/\#/);
	my ($chr,$Mv,$ident)=split /\s+/,$_;
		push  @{$hash1{$chr}},[$Mv,$ident];
	

}
close LIST;

#print Dumper  %hash1;die;

foreach my $key(keys %hash1){
#	if($hash1{$key}[0][1] >=60){
		print   OUT "$key\t$hash1{$key}[0][0]\n";
#	}
}
close OUT;



#####################################################################################
# End Time
my $Time_End;
$Time_End = &formate_datetime(localtime(time()));
print "\nEnd Time :[$Time_End]\n\n";

## SUB
# absolute_dir
sub ABSOLUTE_DIR{
	my $cur_dir = `pwd`;
	$cur_dir =~ s/\n$//;
	my ($in,$type) = @_;
	my $return = "";
	if ($type eq "file") {
		my $dir = dirname($in);
		my $filename = basename($in);
		chdir $dir;
		$dir = `pwd`;
		$dir =~ s/\n$//;
		$return = "$dir/$filename";
	}elsif ($type eq "dir"){
		chdir $in;
		$return = `pwd`;
		$return =~ s/\n$//;
	}else{
		warn "Warning juet for the file and dir [$in]\n";
		exit;
	}
	chdir $cur_dir;
	return $return;
}

# formate_datetime
sub formate_datetime()
{
	my($sec, $min, $hour, $day, $mon, $year, $wday, $yday, $isdst) = @_;
	$wday = $yday = $isdst = 0;
	sprintf("%4d-%02d-%02d %02d:%02d:%02d", $year+1900, $mon+1, $day, $hour, $min, $sec);
}

# &show_log("txt")
sub show_log()
{
	my ($txt) = @_ ;
	my $time = time();
	my $Time = &formate_datetime(localtime($time));
	print "$Time:\t$txt\n" ;
	return ($time) ;
}
## &run_or_die("cmd");
sub run_or_die()
{
	my ($cmd) = @_ ;
	&show_log($cmd);
	my $flag = system("$cmd") ;
	if ($flag != 0){
		&show_log("Error: command fail: $cmd");
		exit(1);
		}
	&show_log("done.");
	return ;
}
## &Run_or_die("work.sh");
sub Run_or_die()
{
	my ($cmd) = @_ ;
	&show_log($cmd);
	if (!-f "$cmd.done"){
	my $flag = system("sh $cmd") ;
	if ($flag != 0){
		&show_log("Error: command fail: $cmd");
		exit(1);
		}
	`touch "$cmd.done" `;
	}
	&show_log("done.");
	return ;
}
# qsub
sub qsub()
{
	my ($shfile, $maxproc,$queue) = @_ ;
	$maxproc ||= 50 ;
	$queue ||= 'general.q' ;
	my $cmd = "sh /share/nas2/genome/bmksoft/tool/qsub_sge_plus/v1.0/qsub_sge.plus.sh --maxproc $maxproc --queue $queue  --resource vf=15G --reqsub $shfile --independent" ;
	&run_or_die($cmd);
	return ;
}

## qsub_mult($shfile, $max_proc, $job_num)
sub qsub_mult()
{
	my ($shfile, $max_proc, $job_num) = @_ ;
	if ($job_num > 500){
		my @shfiles = &cut_shfile($shfile);
		for my $file (@shfiles){
			&qsub($file, $max_proc);
		}
	}
	else{
		&qsub($shfile, $max_proc) ;
	}
}

#my @shfiles = &cut_shfile($shfile);
sub cut_shfile()
{
	my ($file) = @_ ;
	my @files = ();
	my $num = 0 ;
	open (IN, $file) || die "Can't open $file, $!\n" ;
	(my $outprefix = $file) =~ s/.sh$// ;
	while (<IN>){
		chomp ;
		if ($num % 500 == 0){
			close(OUT);
			my $outfile = "$outprefix.sub_".(int($num/500)+1).".sh" ;
			push @files, $outfile ;
			open (OUT, ">$outfile") || die "Can't creat $outfile, $!\n" ;
		}
		print OUT $_, "\n" ;
		$num ++ ;
	}
	close(IN);
	close(OUT);

	return @files ;
}

# USAGE
sub USAGE{
	my $usage =<<USAGE;
Description:	$Function
	Version:	$Ver	$Ver_describe
Usage:
	Example: perl $0 -i infile -o outfile
	Options:
		Forced parameters:
			-i     	<infile>	the file name of input file,forced.
			-o     	<outfile>	the file name of out file
		Optional parameters:
			-h	<help>		help
USAGE
	print $usage;
	exit(1);
}
