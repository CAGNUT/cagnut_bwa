module CagnutBwa
  class Util
    attr_accessor :bwa, :config

    def initialize config
      @config = config
      @bwa = CagnutBwa::Base.new
    end

    def aln_one_fastq dirs, filename = nil
      bwa.aln_one_fastq dirs, filename
    end

    def samp_one_fastq dirs, previous_job_id = nil, filename = nil
      bwa.samp_one_fastq dirs, previous_job_id, filename
    end

    def aln dirs, previous_job_id = nil, filename = nil
      bwa.aln dirs, previous_job_id, filename
    end

    def samp dirs, previous_job_id = nil, filename = nil
      bwa.samp dirs, previous_job_id, filename
    end

    def mem dirs, filename = nil
      bwa.mem dirs, filename
    end
  end
end
