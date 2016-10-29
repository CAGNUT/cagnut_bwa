module CagnutBwa
  class AlnOneFastq
    extend Forwardable

    def_delegators :'Cagnut::Configuration.base', :sample_name, :prefix_name, :dodebug,
                   :ref_fasta, :jobs_dir, :data_type
    def_delegators :'CagnutBwa.config', :aln_params

    def initialize opts = {}
      @order = sprintf '%02i', opts[:order]
      @input = opts[:input].nil? ? "#{seqs_path}" : opts[:input]
      abort('Cant recognized sequence files') if @input.nil?
      @input2 = File.expand_path fetch_filename(@input), File.dirname(@input) if @input.match '_1_'
      @output = "#{opts[:dirs][:output]}/#{File.basename(@input).gsub('.gz', '').gsub('.txt','.sai')}"
      @output2 = "#{opts[:dirs][:output]}/#{fetch_filename(@output)}" if @input.match '_1_'
      @job_name = "#{prefix_name}_#{sample_name}_Aln_one_fastq"
    end

    def fetch_filename file
      filename = File.basename(file)
      if filename.match '_R1_'
        filename.gsub '_R1_', '_R2_'
      elsif filename.match '_1_'
        filename.gsub '_1_', '_2_'
      end
    end

    def run previous_job_id = nil
      puts "Submitting bwa_aln_one_fastq #{sample_name}"
      script_name = generate_script
      ::Cagnut::JobManage.submit script_name, @job_name, queuing_options(previous_job_id)
      @job_name
    end

    def queuing_options previous_job_id = nil
      threads = 2
      {
        previous_job_id: previous_job_id,
        var_env: [fastq_dir, sai_dir, threads],
        adjust_memory: ['h_vmem=3.4G'],
        parallel_env: [threads],
        tools: ['bwa', 'aln']
      }
    end

    def aln_params_for_r1
      array = aln_params.dup
      array.insert 1, 'aln'
      array << "#{ref_fasta}"
      array << "-f #{@output}"
      array << "#{@input}"
      array.uniq
    end

    def aln_params_for_r2
      array = aln_params.dup
      array.insert 1, 'aln'
      array << "#{ref_fasta}"
      array << "-f #{@output2}"
      array << "#{@input2}"
      array.uniq
    end

    def generate_script
      script_name = "#{@order}_bwa_aln_one_fastq"
      file = File.join jobs_dir, "#{script_name}.sh"
      File.open(file, 'w') do |f|
        f.puts <<-BASH.strip_heredoc
          #!/bin/bash
          echo "#{script_name} is starting at $(date +%Y%m%d%H%M%S)" >> "#{jobs_dir}/finished_jobs"
          if [[ #{@input} =~ _1_ ]]
          then
            #{aln_params_for_r2.join(" \\\n            ")} \\
              #{::Cagnut::JobManage.run_local}
          else
          fi

          #{aln_params_for_r1.join(" \\\n            ")} \\
            #{::Cagnut::JobManage.run_local}

          if [ ! -s "#{@output}" ]
          then
            echo "Missing SAI:#{@output} file!"
            exit 100
          fi
          echo "#{script_name} is finished at $(date +%Y%m%d%H%M%S)" >> "#{jobs_dir}/finished_jobs"

        BASH
      end
      File.chmod(0700, file)
      script_name
    end
  end
end
