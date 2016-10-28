require 'cagnut_bwa/functions/aln'
require 'cagnut_bwa/functions/samp'
require 'cagnut_bwa/functions/aln_one_fastq'
require 'cagnut_bwa/functions/samp_one_fastq'
require 'cagnut_bwa/functions/mem'

module CagnutBwa
  class Base
    def aln dirs, previous_job_id, input = nil
      opts = { input: input, dirs: dirs }
      CagnutBwa::Aln.new(opts).run previous_job_id
    end

    def samp dirs, previous_job_id = nil, input = nil
      opts = { input: input, dirs: dirs }
      CagnutBwa::Samp.new(opts).run previous_job_id
    end

    def aln_one_fastq dirs, input = nil
      opts = { input: input, dirs: dirs }
      CagnutBwa::AlnOneFastq.new(opts).run
    end

    def samp_one_fastq dirs, previous_job_id = nil, input = nil
      opts = { input: input, dirs: dirs }
      CagnutBwa::SampOneFastq.new(opts).run previous_job_id
    end

    def mem dirs, input = nil
      opts = { input: input, dirs: dirs }
      CagnutBwa::Mem.new(opts).run
    end
  end
end
