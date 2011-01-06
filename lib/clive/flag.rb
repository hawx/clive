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
    # @param names [Array[Symbol]]
    #   An array of names the flag can be invoked by. Can contain a long name
    #   and/or a short name.
    #
    # @param desc [String]
    #   A description of the flag.
    #
    # @param args [String, Array, Range]
    #   Either, a string showing the arguments to be given, eg.
    #     
    #     "FROM"          # single argument required, or
    #     "[FROM]"        # single optional argument, or
    #     "FROM TO"       # multiple arguments required, or
    #     "FROM [VIA] TO" # multiple arguments with optional argument
    #
    #   OR an array of acceptable inputs, eg.
    #
    #     %w(large small medium) # will only accept these arguments
    #   
    #   OR a range, showing the acceptable inputs, eg.
    #     1..10 #=> means 1, 2, 3, ..., 8, 9, 10
    #
    # @yield [String] 
    #   A block to be run if switch is triggered, will always be passed a string
    #
    def initialize(names, desc, args, &block)
      @names = Clive::Array.new(names.map(&:to_s))
      @args  = Clive::Array.new
      
      # Need to be able to make each arg_name optional or not
      # and allow for type in future
      args.each do |i|
        case i
        when String
          i.split(' ').each do |arg|
            optional = false
            if arg[0] == "["
              optional = true
              arg = arg[1..-2]
            end
            @args << {:name => arg, :optional => optional}
          end
        else
          @args = i
        end
      end

      if @args.empty?
        @args = [{:name => "ARG", :optional => false}]
      end
      
      @desc  = desc
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