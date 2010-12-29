require 'clive/exceptions'
require 'clive/tokens'
require 'clive/ext'

require 'clive/option'
require 'clive/command'
require 'clive/switch'
require 'clive/flag'
require 'clive/bool'

require 'clive/output'
require 'clive/formatter'

module Clive

  # A module wrapping the command line parsing of clive. In the future this
  # will be the only way of using clive.
  #
  # @example
  #
  #   require 'clive/parser'
  # 
  #   class CLI
  #     include Clive::Parser
  #   
  #     @@opts ||= {}
  #     def self.opts
  #       @@opts
  #     end
  #   
  #     switch :v, :verbose, "Run verbosely" do
  #       opts[:verbose] = true
  #     end
  #   end
  #
  #   CLI.parse ARGV
  #   p CLI.opts
  #
  module Parser
  
    def self.included(klass)
      @@klass = klass
      @@klass.extend(self)
      @@base = Clive::Command.new(true)
    end
  
    def parse(argv)
      @@base.run(argv)
    end
    
    def flag(*args, &block)
      @@base.flag(*args, &block)
    end
    
    def switch(*args, &block)
      @@base.switch(*args, &block)
    end
    
    def command(*args, &block)
      @@base.command(*args, &block)
    end
    
    def bool(*args, &block)
      @@base.bool(*args, &block)
    end

  end
end
