module Clive
  
  # @abstract
  #
  # Formats the full help string displayed when the +help+ command is used
  # or the +--help+ option is invoked. This can be replaced by a class of
  # your own design if necessary. The only requirements are that it must 
  # respond to {#to_s} which should return the help string, and respond to
  # {#header=}, {#footer=}, {#options=} and {#commands=}.
  #
  # Then it is just a case of passing an instance of the new formatter to
  # {Clive.run}. You can also use a different formatter for commands by 
  # passing it when creating them.
  #
  # @example
  #
  #   class MainFormatter
  #     # ...
  #   end
  #
  #   class CommandFormatter
  #     # ...
  #   end
  #
  #   # Uses MainFormatter
  #   class CLI
  #     # ...
  #
  #     # Uses CommandFormatter
  #     command :new, formatter: CommandFormatter.new do
  #       # ...
  #     end
  #
  #     # Uses MainFormatter
  #     command :normal do
  #       # ...
  #     end
  #   end
  #
  #   CLI.run formatter: MainFormatter.new
  #
  class Formatter
    
    attr_writer :header, :footer, :options, :commands
    
    def initialize(opts={})
      @opts = opts
    
      @header, @footer = "", ""
      @commands, @options = [], []
    end
    
    def to_s
      ""
    end
    
    def inspect
      "#<#{self.class.name} @opts=#@opts>"
    end
  end
  
end