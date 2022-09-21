#!/usr/bin/perl -w                                                                                                                                                                                                                      
use strict;
use warnings;
use Getopt::Long;
use FindBin qw($Bin $Script);
#==============================================================
use lib "$Bin";
use newPerlBase;
my $Title="Ref_Trans";												#���̵����ƣ�����
my $version="v1.2.1";												#���̰汾������
#my %config=%{readconf("/home/user1/script.cfg")};					#���̰汾�����ļ�·��������
#==============================================================
my ($input,$dOut,$test);
GetOptions(
			"in:s"=>\$input,
			"od:s"=>\$dOut,
			"test"=>\$test,
			);
die if (!defined $dOut);
createLog($Title,$version,$$,"$dOut/log/",$test);				#����������־�ļ���һ�����û����Ŀ¼���ɣ�һ����ͳһĿ¼���ɣ�����ͳ�ƣ���ʼ��ʱ������
mkdirOrDie("$dOut/work_sh");									#������Ҫִ����������ɵ�shell�ļ��м�¼��ִ�У���ѡ
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

#==============================================================						# ���̿���
#pipeline control
#my $step1start=time();																#ÿһ����ʼ��ʱ������
stepStart(1,"Mapping && Annotation");
runOrDie("$dOut/work_sh/step1.sh");													#��qsub��������shell�ļ���qsub�����������ļ�ָ��������
#qsubOrDie("$dOut/work_sh/step1.sh","general.q",1,"1G");		#��qsub��������shell�ļ���qsub�����������ļ�ָ��������
stepTime(1);																		#ÿһ��������ʱ��ͳ�ƣ�����
totalTime();																		#������ʱ��ͳ�ƣ�����
#==============================================================
