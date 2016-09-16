#!/bin/sh

###
# Needs samtools v1.3.*
# Assumes $SAMTOOLS variable containing path to samtools binary
# Assumes $PICARD variable containing path to picard.jar 
# Note: Proper argument parsing has yet to be implemented.
###

###
# Vars
# TODO: proper usage information and paramter parsing
###
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
