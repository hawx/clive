class Clive
  
  # general problem
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
  
  # general problem with input
  class ParseError < CliveError
    def reason; "parse error"; end
  end
  
  # a flag has a missing argument
  class MissingArgument < ParseError
    def reason; "missing argument"; end
  end
  
  # a flag has a wrong argument
  class InvalidArgument < ParseError
    def reason; "invalid argument"; end
  end
  
  # a option that wasn't defined has been found
  class InvalidOption < ParseError
    def reason; "invalid option"; end
  end
  
  class MissingLongName < CliveError
    def reason; "missing long name"; end
  end
  
end
