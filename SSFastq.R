## This script is used to stat fastq file by Reseqtools(iTools) ##
#================================================================#

## Reseqtools : https://github.com/BGI-shenzhen/Reseqtools.git
## He W , Zhao S , Liu X , et al. ReSeqTools: an integrated toolkit for large-scale next-generation sequencing based resequencing analysis[J]. Genetics and Molecular Research, 2013, 12(4):6275-6283.

## Usage example :
## $ Rscript SSFastq sample1_1.fq sample1_2.fq sample1.ss 2
##  - SSFastq : This R script.
##  - sample1_1.fq : pair-end sequence fastq file 1.
##  - sample1_2.fq : pair-end sequence fastq file 2.
##  - sample1: sample name.
##  - 10 : threads (optional, default is 2)
library(data.table)
setwd("/stort/whzhang/peach_3samples_reseq/Clean/")

## please change the iTools path ##
iTools <- "/storo/Apple_whzhang/stat/Reseqtools-master/iTools_Code/iTools"

file.name <- c("Peach_E83-R01-I_good_1.clean.fq","Peach_E83-R01-I_good_2.clean.fq","R01",10)
file.name <- args(T)

if (length(file.name) == 3){
  threads = 2
}else{
  threads = file.name[4]
}

itools.name <- paste(file.name[3],".itools.res",sep = "")
ssf.name <- paste(file.name[3],".ssf.res",sep = "")
system(paste(iTools,"Fqtools stat -InFq",file.name[1],"-InFq",file.name[2],"-OutStat",itools.name,"-CPU",threads))

# Q20 
base.q20 <- round(as.numeric(system(paste("grep Q20",itools.name,"|grep Base |awk  '{print $5}'|cut -d '%' -f 1|awk '{sum+=$1}END{print sum/NR}'"),intern = T)),2)
read.q20 <- round(as.numeric(system(paste("grep Q20",itools.name,"|grep Read |awk  '{print $5}'|cut -d '%' -f 1|awk '{sum+=$1}END{print sum/NR}'"),intern = T)),2)

# Q30 
base.q30 <- round(as.numeric(system(paste("grep Q30",itools.name,"|grep Base |awk  '{print $5}'|cut -d '%' -f 1|awk '{sum+=$1}END{print sum/NR}'"),intern = T)),2)
read.q30 <- round(as.numeric(system(paste("grep Q30",itools.name,"|grep Read |awk  '{print $5}'|cut -d '%' -f 1|awk '{sum+=$1}END{print sum/NR}'"),intern = T)),2)

# GC
gc <- round(as.numeric(system(paste("grep GC",itools.name,"|awk '{print $2}'|cut -d '%' -f 1|awk '{sum+=$1}END{print sum/NR}'"),intern = T)),2)

# Total number
total.read.number <- system(paste("grep ReadNum",itools.name,"|awk '{sum+=$2}END{print sum}'"),intern = T)
total.base.number <- system(paste("grep BaseNum",itools.name,"|awk '{sum+=$4}END{print sum}'"),intern = T)

output.file <- data.table(SampleName = file.name[3],BaseQ20 = base.q20, BaseQ30 = base.q30, ReadQ20 = read.q20, ReadQ30 = read.q30, GC = gc, ReadNum = total.read.number, BaseNum = total.base.number)
fwrite(output.file, file = ssf.name, sep = "\t")
