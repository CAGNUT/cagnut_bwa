module CagnutBwa
  module CheckTools
    def check_tool tools_path, refs=nil
      super if defined?(super)
      ver = check_bwa tools_path['bwa'], refs['ref_fasta']
      check_bwa_index tools_path['bwa'], refs['ref_fasta'] if !ver.blank?
    end

    def check_bwa path, ref_path
      check_tool_ver 'BWA' do
        `#{path} 2>&1 | grep Version | cut -f2 -d ' '` if path
      end
    end

    def check_bwa_index tool_path, ref_path
      tool = 'Bwa Index'
      file = "#{ref_path}.ann"
      command = "#{tool_path} index #{ref_path}"
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
