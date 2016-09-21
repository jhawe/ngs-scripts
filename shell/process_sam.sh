#!/bin/sh

###
# Needs samtools v1.3.*
# Assumes $SAMTOOLS variable containing path to samtools binary
# Assumes $PICARD variable containing path to picard.jar
# Note: Proper argument parsing has yet to be implemented.
###

# define help var (found on stackoverflow)
read -d '' help <<- EOF
 usage: process_sam.sh [-q QVAL] [-d] [-m <bwa|bowtie>] -i <INPUT.(SAM|FASTQ)> -o <OUTDIR>

 TODO: proper help
 Report bugs to: https://github.com/jhawe/ngs-scripts
 home page: -
EOF

###
# Vars
# TODO: finish proper usage information and paramter parsing
###
while getopts ":m:i:o:q:d" opt ; do
 case $opt in
  m)
   echo "Mapping not yet implemented. you have to provide a sam file." >&2
   echo $help
   exit;
   ;;
  :)
   echo "Argument for option -$OPTARG is empty." >&2
   echo $help
   exit;
   ;;
  \?)
   echo "Invalid option." >&2
   echo $help
 exit;
   ;;
  i)
   input=$OPTARG
   ;;
  o)
   outdir=$OPTARG
   ;;
  q)
   qval=$OPTARG
   ;;
  d)
   dedup=T
   ;;
 esac
done

if [ -z $input ] || [ -z $outdir ] ; then
 echo $help
 exit:
fi
if [ -z $qval ] ; then
 echo $help
fi
exit

sam=$1
outdir=$2
if [ "$#" == "3" ] ; then
 prefix=${outdir}/$3 
else
 prefix=${outdir}/$(basename ${sam} .sam)
fi

echo "Input $sam"
echo "Output: $outdir"
echo "Samtools: $SAMTOOLS"
echo "Picard: $PICARD"

# set samtools path
if [ -n "$VAR" ] ; then
 st=${SAMTOOLS}
else
 st=samtools
fi

if [ -z "$PICARD" ] ; then
 echo "$PICARD not set."
 exit
fi

###
# start the processing
###
echo "Converting and sorting."
$st view -bS -q 30 ${sam} \
| $st sort - > ${prefix}.bam
$st index ${prefix}.bam


###
# Dedupping.
###
echo "Removing duplicates."
tmp=${prefix}.tmp
met=${prefix}.met
java -jar ${PICARD} MarkDuplicates REMOVE_DUPLICATES=True I=${prefix}.bam O=${tmp} M=${met}

echo "Cleaning up and indixing."
mv ${tmp} ${prefix}.bam
$st index ${prefix}.bam

echo "All done."
echo "Output file: ${prefix}.bam"
