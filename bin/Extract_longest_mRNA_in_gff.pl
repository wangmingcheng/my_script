
#!/usr/bin/perl -w
use strict;
use warnings;
use Getopt::Long;
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $BEGIN_TIME=time();
my $version="1.0.0";
#######################################################################################

# ------------------------------------------------------------------
# GetOptions
# ------------------------------------------------------------------
my ($gff,$outdir);
GetOptions(
				"help|?" =>\&USAGE,
				"i:s"=>\$gff,
				) or &USAGE;
&USAGE unless ($gff );
$outdir=AbsolutePath("f_dir",$gff);
my $name=basename($gff);
#######################################################################################
#A02     .       gene    2027996 2029910 .       +       .       ID=evm.TU.A02.200;Name=EVM%20prediction%20A02.200
#A02     .       mRNA    2027996 2029910 .       +       .       ID=evm.model.A02.200;Parent=evm.TU.A02.200;Name=EVM%20prediction%20A02.200
#A02     .       exon    2027996 2028107 .       +       .       ID=evm.model.A02.200.exon1;Parent=evm.model.A02.200
#A02
my %hash_gene;
my %hash_mRNA;
my %hash_gene_mRNA_len;
my $gid;
my $mid;

open(IN,$gff)or die $!;
while(<IN>)
{
 chomp;
next if(/\#/);
 next if(/^$/);
 my($scaf,$datatype,$type,$start,$end,undef,$dir,undef,$info)=split(/\t/,$_);
 if($type eq "gene")
  {
   ($gid)=split(/;/,$_);
   $gid=~ s/ID=//g;
  $hash_gene{$gid}=$_;
  }
  elsif($type eq "mRNA")
  {
   ($mid)=split(/;/,$_);
   $mid=~ s/ID=//g;
   push @{$hash_mRNA{$gid}{$mid}},$_;
  }
  elsif($type eq "CDS")
  {
   my $len =abs($start -$end)+1;
   $hash_gene_mRNA_len{$gid}{$mid}+=$len;
   push @{$hash_mRNA{$gid}{$mid}},$_; 
 }
# else 
 #{
#   push @{$hash_mRNA{$gid}{$mid}},$_;	 
# }
}
close(IN);
my %hash_GM;
foreach my $gene (keys %hash_gene_mRNA_len)
 { 
  my $tlen=0;
  my $GmRNA;
  foreach my $mRNA(keys %{$hash_gene_mRNA_len{$gene}})
  {
   if($hash_gene_mRNA_len{$gene}{$mRNA} >$tlen)
     {
      $tlen=$hash_gene_mRNA_len{$gene}{$mRNA};
      $GmRNA=$mRNA;
     }
  }
  $hash_GM{$gene}=$GmRNA;
 } 
open(XX,">$outdir/$name.longest.evm.gff")or die $!;
foreach my $g (keys %hash_GM)
{
	my @tmp=split/\t/,$hash_gene{$g};
#	$tmp[1]="EVM";
 print XX join("\t",@tmp)."\n";
 my @arr=@{$hash_mRNA{$g}{$hash_GM{$g}}};
 foreach my $line (@arr)
 {
 	my @tmp=split/\t/,$line;
 #	$tmp[1]="EVM";
 print XX join("\t",@tmp)."\n";
 }
} 
close(XX);
#######################################################################################
print STDOUT "\nDone. Total elapsed time : ",time()-$BEGIN_TIME,"s\n";
#######################################################################################

# ------------------------------------------------------------------
# sub function
# ------------------------------------------------------------------

sub AbsolutePath
{		#获取指定目录或文件的决定路径
        my ($type,$input) = @_;

        my $return;
	$/="\n";

        if ($type eq 'dir')
        {
                my $pwd = `pwd`;
                chomp $pwd;
                chdir($input);
                $return = `pwd`;
                chomp $return;
                chdir($pwd);
        }
        elsif($type eq 'f_dir')
        {
                my $pwd = `pwd`;
                chomp $pwd;

                my $dir=dirname($input);
                my $file=basename($input);
                chdir($dir);
                $return = `pwd`;
                chomp $return;
                $return .="\/";
                chdir($pwd);
        }
		 elsif($type eq 'file')
        {
                my $pwd = `pwd`;
                chomp $pwd;

                my $dir=dirname($input);
                my $file=basename($input);
                chdir($dir);
                $return = `pwd`;
                chomp $return;
                $return .="\/".$file;
                chdir($pwd);
        }
        return $return;
}


sub GetTime {
	my ($sec, $min, $hour, $day, $mon, $year, $wday, $yday, $isdst)=localtime(time());
	return sprintf("%4d-%02d-%02d %02d:%02d:%02d", $year+1900, $mon+1, $day, $hour, $min, $sec);
}


sub USAGE {#
	my $usage=<<"USAGE";
Program:
Version: $version
Contact:zhanghailun<zhanghl\@biomarker.com.cn> 

Usage:
  Options:
  -i  <file>   Input file, forced
  -h         Help

USAGE
	print $usage;
	exit;
}
