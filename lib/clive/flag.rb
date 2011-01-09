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
      @args = {
        :type => :list,
        :arguments => [{:name => "ARG", :optional => false}]
      }
      
      # Need to be able to make each arg_name optional or not
      # and allow for type in future
      args.each do |i|
        case i
        when String
          if i[-3..-1] == "..."
            @args = {:type => :splat, :base_name => i[0..-4]}
          
          else
            @args = {:type => :list, :arguments => []}
            i.split(' ').each do |arg|
              optional = false
              if arg[0] == "["
                optional = true
                arg = arg[1..-2]
              end

              @args[:arguments] << {:name => arg, :optional => optional}
            end
          end
          
        when Range
          @args = {:type => :range, :range => i}
          
        when Array
          @args = {:type => :choice, :items => i}
        end
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
      case @args[:type]
      when :list
        args = optimise_fill(args, @args[:arguments].map {|i| !i[:optional] })
      when :choice, :range
        unless @args.to_a.map{|i| i.to_s}.include?(args[0])
          raise InvalidArgument.new(args)
        end
      when :splat
        args = [args]
      end
      @block.call(*args)
    end
    
    
    # @param type [Symbol]
    #   Can be passed three things; :all, returns size of all arguments; :optional
    #   returns all optional arguments; :mandatory, returns size of mandatory arguments.
    def arg_size(type=:all)
      case @args[:type]
      when :list
        case type
        when :all
          @args[:arguments].size
        when :optional
          @args[:arguments].find_all {|i| i[:optional] == true }.size
        when :mandatory
          @args[:arguments].find_all {|i| i[:optional] == false }.size
        end
      
      when :choice, :range
        (type == :optional) ? 0 : 1
      
      when :splat
        case type
        when :all
          1.0/0 # Infinity!
        when :optional
          1.0/0 # Infinity!
        when :mandatory
          1
        end
      end
    end
    
    def args_to_strings
      case @args[:type]
      when :list
        r = []
        @args[:arguments].each do |arg|
          if arg[:optional]
            r << "[" + arg[:name] + "]"
          else
            r << arg[:name]
          end
        end
        r
        
      when :choice
        [""]
      
      when :range
        [""]
      when :splat
        ["<#{@args[:base_name]}1 #{@args[:base_name]}2 ...>"]
      end
    end
    
    def options_to_strings
      case @args[:type]
      when :list
        ['']
      when :choice
        @args[:items]
      when :range
        [@args[:range].to_s]
      when :splat
        ['']
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
    
    
    # Attempts to fill +self+ with values from +input+, giving priority to 
    # true, then false. If insufficient input to fill all false will use nil.
    #
    # @param [Array] input array of values to fill +self+ with
    # @return [Array] filled array
    #
    # @example
    #
    #   [true, false, false, true].optimise_fill(["a", "b", "c"])
    #   #=> ["a", "b", nil, "c"]
    #
    #
    def optimise_fill(input, match)
      diff = input.size - match.reject{|i| i == false}.size
      
      result = []
      match.each_index do |i|
        curr_item = match[i]
        if curr_item == true
          result << input.shift
        else
          if diff > 0
            result << input.shift
            diff -= 1
          else
            result << nil
          end
        end
      end
      result
    end
    
    
  end
end