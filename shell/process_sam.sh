#!/bin/sh

###
# currently just a test for github.
# Needs samtools v1.3.*
# Assumes samtools has been installed to the personal library
###

###
# Vars
# TODO: proper usage informaiton and paramter parsing
###
sam=$1
outdir=$2
if [ "$#" == "3" ] ; then
 prefix=${outdir}/$3
elif
 prefix=${outdir}/$(basename ${sam} .sam)
fi

# set samtools path
st=~/bin/samtools

###
# start the processing
###
st view -bS -q 30 ${sam} \
| st sort - > ${prefix}.bam
st index ${prefix}.bam


# TODO: complete dedubbing
# set picard tools location
picard=...
tmp=${prefix}.tmp
met=${prefix}.met
java -jar ${picard} REMOVE_DUPLICATES INPUT=${prefix}.bam OUTPUT=${tmp} METRICS=${met}
