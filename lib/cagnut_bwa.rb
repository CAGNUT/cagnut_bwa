require "cagnut_bwa/version"

module CagnutBwa
  class << self
    def config
      @config ||= begin
        CagnutBwa::Configuration.load(Cagnut::Configuration.config, Cagnut::Configuration.params['bwa'])
        CagnutBwa::Configuration.instance
      end
    end
  end
end

require 'cagnut_bwa/configuration'
require 'cagnut_bwa/check_tools'
require 'cagnut_bwa/base'
require 'cagnut_bwa/util'
