#!/bin/bash

cd "#{jobs_dir}/../"
echo "#{script_name} is starting at $(date +%Y%m%d%H%M%S)" >> "#{jobs_dir}/finished_jobs"
echo #{mem_params.join("\s")}
#{mem_params.join(" \\\n  ")} \\
  #{run_local}

#force error when missing/empty sam . Would prevent continutation of pipeline
if [ ! -s #{output} ]
then
  echo "Missing SAM:#{output} file!"
  exit 100
fi

# check STDOUT has correct termination string
HASENDING=$(tail -5 #{jobs_dir}/#{script_name}.err  | grep " Processed")

if [ -n "$HASENDING" ]
then
  OK=1
else
  #echo " empty variable"
  echo "Error: Improper stdout termination"
  echo $EXITSTATUS
  echo "bwa (mem) has likely crashed. Exiting"
  exit 100
fi
echo "#{script_name} is finished at $(date +%Y%m%d%H%M%S)" >> "#{jobs_dir}/finished_jobs"
