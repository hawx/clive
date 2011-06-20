module Clive

  class Command < Option
  
    def initialize(names, desc="", opts={}, &block)
      @names = names
      @desc  = desc
      @opts  = opts
      @block = block
      
      @options = []
      current_desc
    end
    
    def current_desc
      r = @_last_desc
      @_last_desc = ""
      r
    end
    
    def option(*args, &block)
      s, l, d, o = nil, nil, current_desc, {}
      args.each do |i|
        case i
          when Symbol then i.size > 1 ? l = i : s = i
          when String then d = i
          when Hash   then o = i
        end
      end
      @options << Option.new(s, l, d, o, &block)
    end
    alias_method :opt, :option
    
    def description(arg)
      @_last_desc = arg
    end
    alias_method :desc, :description
    
    def has_option?(arg)
      @options.any? {|i| i.short == arg || i.long == arg }
    end
    
    def [](arg)
      @options.find {|i| i.short == arg || i.long == arg }
    end
  
  end
end