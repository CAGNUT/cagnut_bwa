#!/bin/bash

cd "#{jobs_dir}/../"
echo "#{script_name} is starting at $(date +%Y%m%d%H%M%S)" >> "#{jobs_dir}/finished_jobs"
#{samp_options.join(" \\\n  ")} \\
  #{run_local}

# check file size less than 1MB

if [ $(stat --printf="%s" "#{output}") -le 1024000 ]
then
  echo "Error with output."
  exit 100
fi

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

PROCESSED=$(tail -5 #{jobs_dir}/#{script_name}.err | grep " sequences have been processed." | grep -o "[0-9]\\\+")

echo "checking stdout file: " #{jobs_dir}/#{script_name}.err
echo "bwa processed" $PROCESSED
echo "#{script_name} is finished at $(date +%Y%m%d%H%M%S)" >> "#{jobs_dir}/finished_jobs"
