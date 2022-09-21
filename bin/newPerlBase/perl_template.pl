#!/usr/bin/perl -w                                                                                                                                                                                                                      
use strict;
use warnings;
use Getopt::Long;
use FindBin qw($Bin $Script);
#==============================================================
use lib "$Bin";
use newPerlBase;
my $Title="Ref_Trans";												#流程的名称，必填
my $version="v1.2.1";												#流程版本，必填
#my %config=%{readconf("/home/user1/script.cfg")};					#流程版本配置文件路径，必填
#==============================================================
my ($input,$dOut,$test);
GetOptions(
			"in:s"=>\$input,
			"od:s"=>\$dOut,
			"test"=>\$test,
			);
die if (!defined $dOut);
createLog($Title,$version,$$,"$dOut/log/",$test);				#创建两份日志文件，一份在用户结果目录生成，一份在统一目录生成，用于统计；开始计时，必填
mkdirOrDie("$dOut/work_sh");									#所有需要执行命令均生成到shell文件中记录并执行，可选
#step 1
my $cmd="echo ok";
open OUT,">$dOut/work_sh/step1.sh";
print OUT $cmd;
close OUT;

#step 2
$cmd="echo ok";
open OUT,">$dOut/work_sh/step2.sh";
print OUT $cmd;
close OUT;

#==============================================================						# 流程控制
#pipeline control
#my $step1start=time();																#每一步开始计时，必填
stepStart(1,"Mapping && Annotation");
runOrDie("$dOut/work_sh/step1.sh");													#用qsub程序运行shell文件，qsub参数由配置文件指定，必填
#qsubOrDie("$dOut/work_sh/step1.sh","general.q",1,"1G");		#用qsub程序运行shell文件，qsub参数由配置文件指定，必填
stepTime(1);																		#每一步的运行时间统计，必填
totalTime();																		#运行总时间统计，必填
#==============================================================
