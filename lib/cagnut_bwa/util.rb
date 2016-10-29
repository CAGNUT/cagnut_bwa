module CagnutBwa
  class Util
    attr_accessor :bwa, :config

    def initialize config
      @config = config
      @bwa = CagnutBwa::Base.new
    end

    def aln_one_fastq dirs, order=1, filename=nil
      job_name = bwa.aln_one_fastq dirs, order, filename
      [job_name, order+1]
    end

    def samp_one_fastq dirs, order=1, previous_job_id=nil, filename=nil
      job_name, filename = bwa.samp_one_fastq dirs, order, previous_job_id, filename
      [job_name, filename, order+1]
    end

    def aln dirs, order=1, previous_job_id = nil, filename=nil
      job_name = bwa.aln dirs, order, previous_job_id, filename
      [job_name, order+1]
    end

    def samp dirs, order=1, previous_job_id=nil, filename=nil
      job_name, filename = bwa.samp dirs, order, previous_job_id, filename
      [job_name, filename, order+1]
    end

    def mem dirs, order=1, filename = nil
      job_name, filename = bwa.mem dirs, order, filename
      [job_name, filename, order+1]
    end
  end
end
