class Clive

  # For general errors with Clive. It stripts most of the backtrace which 
  # you don't really want, and allows you to set nice error messages
  # using {.reason}. Arguments can be passed and then used in messages by 
  # referencing with +#n+ tokens, where +n+ is the index of the argument.
  #
  # A lot of this is pulled from OptionParser::ParseError see
  # http://ruby-doc.org/stdlib/libdoc/optparse/rdoc/index.html.
  #
  # @example
  #
  #   class MissingArgumentError < Error
  #     reason 'missing argument for #0'
  #   end
  #
  #   raise MissingArgumentError.new(some_option)
  #
  class Error < StandardError
    attr_accessor :args
    
    # @param args
    #   Arguments that can be accessed with '#n' in {.reason}.
    def initialize(*args)
      @args = args
    end
    
    # Removes all references to files which are not the file being run
    # unless in $DEBUG mode.
    def self.filter_backtrace(array)
      unless $DEBUG
        array = [$0]
      end
      array
    end
    
    # Set the reason for the error class.
    # @param str [String]
    def self.reason(str)
      @reason = str
    end
    
    # Accessor for the reason set with {.reason}.
    def self._reason
      @reason
    end
    
    def set_backtrace(array)
      super(self.class.filter_backtrace(array))
    end
    
    # Build the message by substituting the arguments into the reason.
    def message
      self.class._reason.gsub(/#\d/) do |i|
        arg = args[i[1].to_i]
        if arg.is_a?(Array)
          arg.map(&:to_s).to_s
        else
          arg.to_s
        end
      end
    end
    alias_method :to_s, :message
    
  end
end