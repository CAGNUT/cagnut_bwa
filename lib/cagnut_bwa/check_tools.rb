module CagnutBwa
  module CheckTools
    def check_tool tools_path
      super if defined?(super)
      check_bwa tools_path['bwa']
      check_bwa_index refs['ref_fasta']
    end

    def check_bwa path
      check_tool_ver 'BWA' do
        `#{path} 2>&1 | grep Version | cut -f2 -d ' '` if path
        check_bwa_index
      end
    end

    def check_bwa_index ref_path
      tool = 'Bwa Index'
      file = "#{ref_path}.ann"
      command = "#{@config['tools']['bwa']} index #{ref_path}"
      check_ref_related file, tool, command
    end


    def check_ref_related file, tool, command
      if File.exist?(file)
        puts "\t#{tool}: Done"
      else
        puts "\t#{tool}: Not Found!"
        puts "\tPlease execute command:"
        puts "\t\t#{command}"
        @check_completed = false
      end
    end
  end
end

Cagnut::Configuration::Checks::Tools.prepend CagnutBwa::CheckTools
