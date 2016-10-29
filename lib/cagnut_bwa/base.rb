require 'cagnut_bwa/functions/aln'
require 'cagnut_bwa/functions/samp'
require 'cagnut_bwa/functions/aln_one_fastq'
require 'cagnut_bwa/functions/samp_one_fastq'
require 'cagnut_bwa/functions/mem'

module CagnutBwa
  class Base
    def aln dirs, order, previous_job_id, input = nil
      opts = { input: input, dirs: dirs, order: order  }
      CagnutBwa::Aln.new(opts).run previous_job_id
    end

    def samp dirs, order, previous_job_id = nil, input = nil
      opts = { input: input, dirs: dirs, order: order  }
      CagnutBwa::Samp.new(opts).run previous_job_id
    end

    def aln_one_fastq dirs, order, input = nil
      opts = { input: input, dirs: dirs, order: order  }
      CagnutBwa::AlnOneFastq.new(opts).run
    end

    def samp_one_fastq dirs, order, previous_job_id = nil, input = nil
      opts = { input: input, dirs: dirs, order: order  }
      CagnutBwa::SampOneFastq.new(opts).run previous_job_id
    end

    def mem dirs, order, input = nil
      opts = { input: input, dirs: dirs, order: order }
      CagnutBwa::Mem.new(opts).run
    end
  end
end
