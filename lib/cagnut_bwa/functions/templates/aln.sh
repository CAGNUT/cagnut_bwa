#!/bin/bash

cd "#{jobs_dir}/../"
echo "#{script_name} is starting at $(date +%Y%m%d%H%M%S)" >> "#{jobs_dir}/finished_jobs"
echo #{aln_params_for_r1.join("\s")}
#{aln_params_for_r1.join(" \\\n  ")} \\
  #{run_local}

#force error when missing/empty sai . Would prevent continutation of pipeline
if [ ! -s "#{output}" ]
then
  echo "Missing SAI:#{output} file!"
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
PROCESSED=$(tail -5 #{jobs_dir}/#{script_name}.err | grep " sequences have been processed." | grep -o "[0-9]\+")

echo "checking stdout file: " #{jobs_dir}/#{script_name}.err
echo "bwa processed" $PROCESSED

if [[ "#{input}" =~ gz$ ]]
then
  LINESFASTQ1=$(gunzip -c "#{input}" | wc -l)
else
# non gz files
  LINESFASTQ1=$(wc -l "#{input}" | cut -d" " -f1 )
fi
  echo "Fastq1 number lines:= " $LINESFASTQ1
  SEQLINES=$[ $LINESFASTQ1 / 4 ]
  echo "Estimated Minimum Sequences:= " $SEQLINES
  if (( "$PROCESSED" >= "$SEQLINES" ))
    then
      echo "Complete."
    else
      echo "Error, incorrect number of processed sequences"
      exit 100
  fi

####################################################################
# PAIR _2_
# run and check pair _2_
#
#
####################################################################

#{aln_params_for_r2.join(" \\\n  ")} \\
  #{run_local}

#force error when missing/empty sai . Would prevent continutation of pipeline
if [ ! -s "#{output2}" ]
then
  echo "Missing SAI:#{output2} file!"
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
PROCESSED=$(tail -5 #{jobs_dir}/#{script_name}.err | grep " sequences have been processed." | grep -o "[0-9]\+")
echo "checking stdout file: " #{jobs_dir}/#{script_name}.err
echo "bwa processed" $PROCESSED

if [[ "#{input2}" =~ gz$ ]]
then
  LINESFASTQ2=$(gunzip -c "#{input2}" | wc -l)
else
# non gz files
  LINESFASTQ2=$(wc -l "#{input2}" | cut -d" " -f1 )
fi
  echo "Fastq2 number lines:= " $LINESFASTQ2
  SEQLINES=$[ $LINESFASTQ2 / 4 ]
  echo "Estimated Minimum Sequences:= " $SEQLINES
  if (( "$PROCESSED" >= "$SEQLINES" ))
    then
      echo "Complete."
    else
      echo "Error, incorrect number of processed sequences"
      exit 100
  fi

echo "#{script_name} is finished at $(date +%Y%m%d%H%M%S)" >> "#{jobs_dir}/finished_jobs"
