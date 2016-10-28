module CagnutBwa
  class SampOneFastq
    extend Forwardable

    def_delegators :'Cagnut::Configuration.base', :sample_name, :prefix_name,
                   :ref_fasta, :jobs_dir, :data_type, :dodebug
    def_delegators :'CagnutBwa.config', :rg_str, :samp_params

    def initizaline opts = {}
      @job_name = "#{prefix_name}_#{sample_name}_Samp"
      @seq = opts[:input].nil? ? "#{seqs_path}" : opts[:input]
      abort('Cant recognized sequence files') if @seq.nil?
      @sai = "#{opts[:dirs][:input]}/#{File.basename(@seq).gsub('.gz', '').gsub('.txt','.sai')}"
      @seq2 = @seq.match('_1_') ? "#{File.expand_path(fetch_filename(@seq), File.dirname(@seq))}" : ''
      @sai2 = @sai.match('_1_') ? "#{opts[:dirs][:input]}/#{fetch_filename(@sai)}" : ''
      @output = "#{opts[:dirs][:output]}/#{sample_name}_sequence.aligned.sam.gz"
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
      puts "Submitting bwaSampOneFastq #{sample_name} RG_STR= #{rg_str}"
      script_name = generate_script
      ::Cagnut::JobManage.submit script_name, @job_name, queuing_options(previous_job_id)
      [@job_name, @output]
    end

    def queuing_options previous_job_id = nil
      {
        previous_job_id: previous_job_id,
        adjust_memory: ['h_vmem=5G'],
        parallel_env: ['30'],
        tools: ['bwa', 'samp']
      }
    end

    def generate_script
      script_name = data_type == 'ONEFASTQ' ? 'bwa_samp_one_fastq' : 'bwa_samse_one_fastq'
      bwa_samp_one_fastq script_name
      script_name
    end

    def samp_one_fastq_options
      array = samp_params.dup
      array.insert 1, 'sampe'
      array << "-r \"#{rg_str}\""
      array << "#{ref_fasta}"
      array << "#{@sai}"
      array << "#{@sai2}"
      array << "#{@seq}"
      array << "#{@seq2} | gzip > #{@output}"
      array.uniq.compact
    end

    def samse_one_fastq_options
      array = samp_params.dup
      array.insert 1, 'sampe'
      array << "-r \"#{rg_str}\""
      array << "#{ref_fasta}"
      array << "#{@sai}"
      array << "#{@seq} | gzip > #{@output}"
      array.uniq.compact
    end

    def bwa_samp_one_fastq script_name
      file = File.join jobs_dir, "#{script_name}.sh"
      path = File.expand_path "../templates/#{script_name}.sh", __FILE__
      template = Tilt.new path
      File.open(file, 'w') do |f|
        f.puts template.render Object.new, job_params(script_name)
      end
      File.chmod(0700, file)
    end

    def job_params script_name
      {
        jobs_dir: jobs_dir,
        script_name: script_name,
        output: @output,
        seq: @seq,
        seq2: @seq2,
        samp_options: (data_type == 'ONEFASTQ' ? 'samp_one_fastq_options' : 'samse_one_fastq_options'),
        run_local: ::Cagnut::JobManage.run_local
      }
    end
  end
end
