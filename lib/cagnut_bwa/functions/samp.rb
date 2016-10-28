module CagnutBwa
  class Samp
    extend Forwardable

    def_delegators :'Cagnut::Configuration.base', :sample_name, :seqs_path,
                   :ref_fasta, :jobs_dir, :dodebug, :prefix_name
    def_delegators :'CagnutBwa.config', :rg_str,:samp_params

    def initialize opts = {}
      @fastq = opts[:input].nil? ? "#{seqs_path}" : opts[:input]
      @fastq2 = File.expand_path fetch_filename(@fastq), File.dirname(@fastq)
      @input = "#{opts[:dirs][:input]}/#{File.basename(@fastq)}.sai"
      @input2 = File.expand_path fetch_filename(@input), File.dirname(@input)
      abort('Cant recognized sequence files') if @input2.nil?
      @output = "#{opts[:dirs][:output]}/#{sample_name}_aligned.sam.gz"
      @job_name = "#{prefix_name}_#{sample_name}_Samp"
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
      puts "Submitting bwaSamp #{sample_name} RG_STR= #{rg_str}"
      script_name = generate_script
      ::Cagnut::JobManage.submit script_name, @job_name, queuing_options(previous_job_id)
      [@job_name, @output]
    end

    def queuing_options previous_job_id = nil
      {
        previous_job_id: previous_job_id,
        adjust_memory: ['h_vmem=5G'],
        tools: ['bwa', 'samp']
      }
    end

    def samp_options
      array = samp_params.dup
      array.insert 1, 'sampe'
      array << "-r \"#{rg_str}\""
      array << "#{ref_fasta}"
      array << "#{@input}"
      array << "#{@input2}"
      array << "#{@fastq}"
      array << "#{@fastq2} | gzip > #{@output}"
      array.uniq.compact
    end

    def generate_script
      script_name = 'bwa_samp'
      file = File.join jobs_dir, "#{script_name}.sh"
      template = Tilt.new(File.expand_path '../templates/samp.sh', __FILE__)
      File.open(file, 'w') do |f|
        f.puts template.render Object.new, job_params(script_name)
      end
      File.chmod(0700, file)
      script_name
    end

    def job_params script_name
      {
        jobs_dir: jobs_dir,
        script_name: script_name,
        input: @input,
        input2: @input2,
        fastq: @fastq,
        fastq2: @fastq2,
        output: @output,
        samp_options: samp_options,
        run_local: ::Cagnut::JobManage.run_local
      }
    end
  end
end
