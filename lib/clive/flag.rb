module Clive
  
  # A switch that takes one or more arguments.
  #   eg. wget --tries=10
  #       wget -t 10
  #
  class Flag < Option
    attr_accessor :args
        
    # Creates a new Flag instance. A flag is a switch that can take one or more
    # arguments.
    #
    # +short+ *or* +long+ can be omitted but not both.
    # +args+ can also be omitted (is "ARG" by default)
    #
    # @overload flag(short, long, args, desc, &block)
    #   @param [Symbol] short single character for short flag, eg. +:t+ => +-t 10+
    #   @param [Symbol] long longer switch to be used, eg. +:tries+ => +--tries=10+
    #   @param [String, Array] args
    #     either a string showing the arguments to be given, eg.
    #    
    #       "FROM"    # single arg, or
    #       "FROM TO" # two args, or
    #       "[VIA]"   # optional arg surrounded by square brackets
    #
    #     or an array of acceptable inputs, eg.
    #
    #       ["large", "medium", "small"] # will only accept these args
    #
    #   @param [String] desc the description for the flag
    #
    # @yield [String] A block to be run if switch is triggered
    #
    def initialize(*args, desc, &block)
      @names = Clive::Array.new
      @args  = Clive::Array.new
      @desc  = desc
      
      # Need to be able to make each arg_name optional or not
      # and allow for type in future
      args.each do |i|
        case i
        when Hash
          case i[:args]
          when String
            i[:args].split(' ').each do |arg|
              optional = false
              if arg[0] == "["
                optional = true
                arg = arg[1..-2]
              end
              @args << {:name => arg, :optional => optional}
            end
          
          when ::Array
            @args = i[:args]
          
          when Range
            @args = i[:args]
          
          end
        when Symbol
          @names << i.to_s
        end
      end
      
      if @args == []
        @args = [{:name => "ARG", :optional => false}]
      end
      
      @block = block
    end
    
    # Runs the block that was given with an argument
    #
    # @param [Array] args arguments to pass to the block
    # @raise [InvalidArgument] only if +args+ is an array of acceptable inputs
    #   and a match is not found.
    def run(args)
      if @args.is_a?(Array) && @args[0].is_a?(Hash)
        args = Clive::Array.new(@args.collect {|i| !i[:optional]}).optimise_fill(args)
      else # list
        unless @args.to_a.map(&:to_s).include? args[0]
          raise InvalidArgument.new(args)
        end
      end
      @block.call(*args)
    end
    
    # @param [Boolean] optional whether to include optional arguments
    # @return [Integer] number of arguments this takes
    def arg_num(optional)
      if @args.is_a?(Array) && @args[0].is_a?(Hash)
        @args.find_all {|i| i[:optional] == optional }.size
      else
        1
      end
    end
    
    def args_to_strings
      if @args.is_a? Range
        [""]
      elsif @args[0].is_a? Hash
        r = []
        @args.each do |arg|
          if arg[:optional]
            r << "[" + arg[:name] + "]"
          else
            r << arg[:name]
          end
        end
        r
      else
        [""]
      end
    end
    
    def arg_size
      if @args.is_a?(Range) || @args.is_a?(Array)
        1
      else
        @args.size
      end
    end
    
    def options_to_strings
      if @args.is_a? Range
        [@args.to_s]
      elsif @args[0].is_a? Hash
        ['']
      else
        @args
      end
    end
    
    def to_h
      {
        'names'   => Clive::Array.new(names_to_strings),
        'desc'    => @desc,
        'args'    => Clive::Array.new(args_to_strings),
        'options' => Clive::Array.new(options_to_strings)
      }
    end
    
  end
end