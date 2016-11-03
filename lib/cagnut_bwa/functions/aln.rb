module CagnutBwa
  class Aln
    extend Forwardable
    def_delegators :'Cagnut::Configuration.base', :sample_name, :dodebug, :seqs_path,
                   :ref_fasta, :jobs_dir, :prefix_name, :pipeline_name
    def_delegators :'CagnutBwa.config', :aln_params

    def initialize opts = {}
      @order = sprintf '%02i', opts[:order]
      @input = opts[:input].nil? ? "#{seqs_path}" : opts[:input]
      @input2 = File.expand_path fetch_filename, File.dirname(@input)
      abort('Cant recognized sequence files') if @input2.nil?
      @output = "#{opts[:dirs][:output]}/#{File.basename(@input)}.sai"
      @output2 = "#{opts[:dirs][:output]}/#{fetch_filename}.sai"
      @job_name = "#{prefix_name}_#{sample_name}_Aln"
    end

    def fetch_filename
      filename = File.basename(@input)
      if filename.match '_R1_'
        filename.gsub '_R1_', '_R2_'
      elsif filename.match '_1_'
        filename.gsub '_1_', '_2_'
      end
    end

    def run previous_job_id = nil
      puts "Submitting bwaAln #{sample_name}"
      script_name = generate_script
      ::Cagnut::JobManage.submit script_name, @job_name, queuing_options(previous_job_id)
      @job_name
    end

    def queuing_options previous_job_id = nil
      threads = 2
      {
        previous_job_id: previous_job_id,
        var_env: [ref_fasta],
        adjust_memory: ["h_vmem=adjustWorkingMem 5G #{threads}"],
        parallel_env: [threads],
        tools: ['bwa', 'aln']
      }
    end

    def aln_params_for_r1
      array = aln_params.dup
      array.insert 1, 'aln'
      array << "#{ref_fasta}"
      array << "#{@input}"
      array << "> #{@output}"
      array.uniq
    end

    def aln_params_for_r2
      array = aln_params.dup
      array.insert 1, 'aln'
      array << "#{ref_fasta}"
      array << "#{@input2} >"
      array << "#{@output2}"
      array.uniq
    end

    def generate_script
      script_name = "#{@order}_bwa_aln"
      file = File.join jobs_dir, "#{script_name}.sh"
      template = Tilt.new(File.expand_path '../templates/aln.sh', __FILE__)
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
        output: @output,
        output2: @output2,
        aln_params_for_r1: aln_params_for_r1,
        aln_params_for_r2: aln_params_for_r2,
        run_local: ::Cagnut::JobManage.run_local
      }
    end
  end
end
