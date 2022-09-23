#!/bin/bash
set -e

# * @Author: Somnvs.WeiGuisheng
# * @Email: weigs@rainbow-genome.com
# * @date: 2022-08-02
#######################################################################
sampleName=$1
fqDir=$2
starIndexDir=$3
gtf=$4
species=$5
thread=$6
outDir=$7

#######################################################################
# 
logger(){
	msg=$1

	datetime=$(date "+%Y-%m-%d %H:%M:%S")
	echo "[$datetime][INFO] "$msg
}

runCmd(){
	cmd=$1
	errorExit=$2

	logger "$cmd"
	eval "$cmd"

	exitCode=$?
	if [[ $errorExit -ne 1 ]]; then
		if [[ $exitCode -ne 0 ]]; then
			echo "[ERROR] an error occurs, program die, exit code:"$exitCode
			exit $exitCode
		fi
	fi
}

#######################################################################
# 
cDNA_Fastq1=$(ls $fqDir/*_cDNA_R1.fq.gz | tr "\n" "," | sed 's/,$//g' | less)
cDNA_Fastq2=$(ls $fqDir/*_cDNA_R2.fq.gz | tr "\n" "," | sed 's/,$//g' | less)
oligo_Fastq1=$(ls $fqDir/*_oligo_R1.fq.gz | tr "\n" "," | sed 's/,$//g' | less)
oligo_Fastq2=$(ls $fqDir/*_oligo_R2.fq.gz | tr "\n" "," | sed 's/,$//g' | less)



echo "=============================================================="
cd $outDir
runCmd "DNBC4tools run --cDNAfastq1 $cDNA_Fastq1 --cDNAfastq2 $cDNA_Fastq2 --oligofastq1 $oligo_Fastq1 --oligofastq2 $oligo_Fastq2 --starIndexDir $starIndexDir --gtf $gtf --name $sampleName --species $species --thread $thread"

#######################################################################


