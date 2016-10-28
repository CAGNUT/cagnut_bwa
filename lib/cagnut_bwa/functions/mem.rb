module CagnutBwa
  class Mem
    extend Forwardable

    def_delegators :'Cagnut::Configuration.base', :sample_name, :seqs_path,
                   :ref_fasta, :jobs_dir, :prefix_name
    def_delegators :'CagnutBwa.config', :rg_str, :mem_params

    def initialize opts = {}
      @input = opts[:input].nil? ? "#{seqs_path}" : opts[:input]
      @input2 = File.expand_path fetch_filename, File.dirname(@input)
      abort('Cant recognized sequence files') if @input2.nil?
      @output = "#{opts[:dirs][:output]}/#{sample_name}_mem.sam"
      @job_name = "#{prefix_name}_#{sample_name}_mem*"
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
      puts "Submitting bwaMem #{sample_name}"
      script_name = generate_script
      ::Cagnut::JobManage.submit script_name, @job_name, queuing_options(previous_job_id)
      [@job_name, @output]
    end

    def queuing_options previous_job_id = nil
      {
        previous_job_id: previous_job_id,
        tools: ['bwa', 'mem']
      }
    end

    def mem_options
      array = mem_params.dup
      array.insert 1, 'mem'
      array << "-M"
      array << "-R \"#{rg_str}\""
      array << "#{ref_fasta}"
      array << "#{@input}"
      array << "#{@input2}"
      array << "> #{@output}"
      array.uniq
    end

    def generate_script
      script_name = 'bwa_mem'
      file = File.join jobs_dir, "#{script_name}.sh"
      template = Tilt.new(File.expand_path '../templates/mem.sh', __FILE__)
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
        output: @output,
        mem_params: mem_options,
        run_local: ::Cagnut::JobManage.run_local
      }
    end
  end
end
