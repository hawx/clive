module Clive
  class Array < ::Array
        
    alias_method :_join, :join
    
    def join(*args)
      case args.size
      when 1
        self._join(args[0])
        
      when 2 # use second for last eg. 1, 2 and 3
        self[0..-2]._join(args[0]) << args[1] << self[-1]
        
      when 3 # prepend and append 1st and 3rd eg. (1, 2, 3)
        if self[0] != ""
          args[0] << self._join(args[1]) << args[2]
        else
          ""
        end
      end
    end
    
  end
end
