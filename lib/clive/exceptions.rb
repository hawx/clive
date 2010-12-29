module Clive
  
  # General problem
  class CliveError < StandardError
    attr_accessor :args
    
    def initialize(*args)
      @args = args
    end
    
    def self.filter_backtrace(array)
      unless $DEBUG
        array = [$0]
      end
      array
    end
    
    def set_backtrace(array)
      super(self.class.filter_backtrace(array))
    end
    
    def message
      self.reason + ': ' + args.join(' ')
    end
    alias_method :to_s, :message
  
  end
  
  # General problem with input
  class ParseError < CliveError
    def reason; "parse error"; end
  end
  
  # Long name is missing for bool
  class MissingLongName < CliveError
    def reason; "missing long name"; end
  end
  
  # A flag has a missing argument
  class MissingArgument < ParseError
    def reason; "missing argument"; end
  end
  
  # A flag has a wrong argument
  class InvalidArgument < ParseError
    def reason; "invalid argument"; end
  end
  
  # An option that wasn't defined has been found
  class NoOptionError < ParseError
    def reason; "invalid option"; end
  end
  
end
