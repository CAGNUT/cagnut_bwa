#!/bin/bash

cd "#{jobs_dir}/../"
echo "#{script_name} is starting at $(date +%Y%m%d%H%M%S)" >> "#{jobs_dir}/finished_jobs"
# File Checking
if [ ! -s "#{input}" ];then
  echo "Error: Missing " #{input}
  exit 100
fi
if [ ! -s "#{input2}" ];then
  echo "Error: Missing " #{input2}
  exit 100
fi

#{samp_options.join(" \\\n  ")} \\
  #{run_local}

# check if file size less than 1MB
if [ $(stat --printf="%s" "#{output}") -le 1024000 ]
then
  echo "Error with output."
  exit 100
fi

# check STDOUT has correct termination string
HASENDING=$(tail -5 #{jobs_dir}/#{script_name}.err | grep " sequences have been processed.")

if [ -n "$HASENDING" ]
then
  OK=1
else
  #echo " empty variable"
  echo "Improper stdout termination"
  exit 100
fi

#check for correct number of sequences processed, based on fastq records
PROCESSED=$(tail -5 #{jobs_dir}/#{script_name}.err | grep " sequences have been processed." | grep -o "[0-9]\\\+")

echo "checking stdout file: " #{jobs_dir}/#{script_name}.err
echo "bwa processed" $PROCESSED

if [[ "#{fastq}" =~ gz$ ]]
then
  LINESFASTQ1=$(gunzip -c "#{fastq}" | wc -l)
  LINESFASTQ2=$(gunzip -c "#{fastq2}" | wc -l)
else
# non gz files
  LINESFASTQ1=$(wc -l "#{fastq}" | cut -d" " -f1 )
  LINESFASTQ2=$(wc -l "#{fastq2}" | cut -d" " -f1 )
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

