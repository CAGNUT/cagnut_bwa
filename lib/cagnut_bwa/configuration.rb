require 'singleton'

module CagnutBwa
  class Configuration
    include Singleton
    attr_accessor :rg_str, :mem_params, :aln_params, :samp_params

    class << self
      def load config, params
        instance.load config, params
      end
    end

    def load config, params
      @config = config
      @params = params
      generate_rg_str
      attributes.each do |name, value|
        send "#{name}=", value if respond_to? "#{name}="
      end
    end

    def attributes
      {
        rg_str: @config['sample']['rg_str'],
        mem_params: add_bwa_path_in_params(@params['mem']),
        aln_params: add_bwa_path_in_params(@params['aln']),
        samp_params: add_bwa_path_in_params(@params['samp'])
      }
    end

    def add_bwa_path_in_params method_params
      return if method_params.blank?
      array = method_params['params'].dup
      array.unshift "#{@config['tools']['bwa']}"
    end

    def generate_rg_str
      @config['samples'].each do |sample|
        arg = %W(
          @RG
          ID:#{sample['rgid']}
          SM:#{sample['name']}
          PL:#{@config['info']['pl']}
          PU:#{sample['pu']}
          LB:#{@config['info']['lb']}
          DS:#{@config['info']['ds']}
          CN:#{@config['info']['cn']}
          DT:#{@config['info']['dt']}
        )
        rg_str = { 'rg_str' => arg.join('\t') }
        sample.merge! rg_str
      end
    end
  end
end
