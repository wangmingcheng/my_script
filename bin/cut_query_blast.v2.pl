#!/usr/local/bin/perl -w

my $ver="0.7777777";
use strict;
use Getopt::Long;
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
use Cwd;
use newPerlBase;
#use utf8;

my ($ref, $query, $cut_num, $pcfg);

GetOptions(
                                "help|?" =>\&USAGE,
                                "r:s"=>\$ref,
				"q:s"=>\$query,
                                "n:i"=>\$cut_num,
                                "pcfg:s"=>\$pcfg
                                ) or &USAGE;
&USAGE unless ($ref and $query and $pcfg);

#Programe start time
my $Time_Start;
$Time_Start = sub_format_datetime(localtime(time()));
print "\nStart Time :[$Time_Start]\n\n";

my %Pconfig=%{readconf($pcfg)};
my $format ||= 6;
my $Evalue ||= 1e-5;
my $cpu ||=80;
$cut_num ||=200;
my $rundir = getcwd();
$ref=&Absolute_dir($ref);
$query=&Absolute_dir($query);
#$out=&ABSOLUTE_DIR($out);

mkdir("work.sh") if (!-d "work.sh");
#Step1 (构建索引)
open O1, ">$rundir/work.sh/step1.makeblastdb.sh";
print O1 "$Pconfig{blast}/makeblastdb -in $ref -dbtype prot -parse_seqids -max_file_sz 4GB\n";
print "$rundir/run_makeblastdb_result\n";
`$Pconfig{blast}/makeblastdb -in $ref -dbtype prot -parse_seqids -max_file_sz 4GB`;

#Step2 分割query文件
open O2, ">$rundir/work.sh/step2.split_query.sh";
print O2 "$Pconfig{seqkit}/seqkit split2 -f -p $cut_num $query\n";
`$Pconfig{seqkit}/seqkit split2 --force -p $cut_num $query`;

#Step3 blastp比对
open O3, ">$rundir/work.sh/step3.runblastp.sh";
my @file=glob("$query.split/*");
foreach my $file (@file){
	print O3  "$Pconfig{blast}/blastp -query $query -db $ref -out $file\_blastp.out -evalue $Evalue -outfmt 6\n";
}

#Step4 qsub任务投递
open O4, ">$rundir/work.sh/step4.qsub.sh";
print O4 "$Pconfig{qsubsh} $rundir/work.sh/step3.runblastp.sh --reqsub --independent -maxproc $cpu --queue $Pconfig{queue}\n";
`$Pconfig{qsubsh} $rundir/work.sh/step3.runblastp.sh --reqsub --independent -maxproc $cpu --queue $Pconfig{queue}`;

`cat $query.split/*blastp.out >blastp.out`;

#Programe end time
my $Time_End;
$Time_End = sub_format_datetime(localtime(time()));
print "\nEnd Time :[$Time_End]\n\n";

###############Subroutines
sub Absolute_dir{ #$pavfile=&ABSOLUTE_DIR($pavfile);
        my $cur_dir=`pwd`;chomp($cur_dir);
        my ($in)=@_;
        my $return="";
        if(-f $in){
                my $dir=dirname($in);
                my $file=basename($in);
                chdir $dir;$dir=`pwd`;chomp $dir;
                $return="$dir/$file";
        }
        elsif(-d $in){
                chdir $in;$return=`pwd`;chomp $return;
        }
        else{
                warn "Warning just for file and dir\n";
                exit;
        }
        chdir $cur_dir;
        return $return;
}

sub sub_format_datetime {#Time calculation subroutine
    my($sec, $min, $hour, $day, $mon, $year, $wday, $yday, $isdst) = @_;
	$wday = $yday = $isdst = 0;
    sprintf("%4d-%02d-%02d %02d:%02d:%02d", $year+1900, $mon+1, $day, $hour, $min, $sec);
}

sub USAGE {#
        my $usage=<<"USAGE";
Program:
Version: $ver
Contact: joyce 

Usage:
  Options:
  -r <file>   Reference pep seq(fasta format), forced
  -q <file>   Query pep seq(fasta format), forced
  -pcfg  <file> the parameter config forced 
  -h         Help

USAGE
        print $usage;
        exit;
}
