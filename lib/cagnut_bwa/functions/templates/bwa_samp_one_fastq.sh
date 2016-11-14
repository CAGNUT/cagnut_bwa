#!/bin/bash

cd "#{jobs_dir}/../"
echo "#{script_name} is starting at $(date +%Y%m%d%H%M%S)" >> "#{jobs_dir}/finished_jobs"
#{samp_options.join(" \\\n  ")} \\
  #{run_local}

# check file size less than 1MB
#
# if [ $(stat --printf="%s" "#{sam_dir}/#{line}_sequence.aligned.sam.gz") -le 1024000 ]
# then
#  echo "Error with output."
#  exit 100
# fi

#check STDOUT has correct termination string
HASENDING=$(tail -5 #{jobs_dir}/#{script_name}.err | grep " sequences have been processed.")

if [ -n "$HASENDING" ]
then
  echo "OUTPUT ok."
else
  #echo " empty variable"
  echo "Improper stdout termination"
  exit 100
fi

#check for correct number of sequences processed, based on fastq records
PROCESSED=$(tail -5 #{jobs_dir}/#{script_name}.err | grep " sequences have been processed." | grep -o -P " \\d+ ")

echo "checking stdout file: " #{jobs_dir}/#{script_name}.err
echo "bwa processed" $PROCESSED

if [[ "#{seq}" =~ gz$ ]]
then

  LINESFASTQ1=$(gunzip -c "#{seq}" | wc -l)
  LINESFASTQ2=$(gunzip -c "#{seq2}" | wc -l)

else
# non gz files
  LINESFASTQ1=$(wc -l "#{seq}" )
  LINESFASTQ2=$(wc -l "#{seq2}" )
fi

echo "Fastq1 number lines:= " $LINESFASTQ1
echo "Fastq2 number lines:= " $LINESFASTQ2

if (( "$LINESFASTQ1" >= "$LINESFASTQ2" ))
then
  SEQLINES=$[ $LINESFASTQ2 / 4 ]
else
  SEQLINES=$[ $LINESFASTQ1 / 4 ]
fi

echo "Estimated Minimum Sequences:= " $SEQLINES

if (( "$PROCESSED" >= "$SEQLINES" ))
then
  echo "Complete."
else
  echo "Error, incorrect number of processed sequences"
  exit 100
fi

echo "#{script_name} is finished at $(date +%Y%m%d%H%M%S)" >> "#{jobs_dir}/finished_jobs"

