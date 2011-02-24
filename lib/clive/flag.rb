module Clive
  
  # A switch that takes one or more arguments.
  #   eg. wget --tries=10
  #       wget -t 10
  #
  class Flag < Option
    attr_reader :args
        
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
    # @param arguments [String, Array, Range]
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
    def initialize(names, desc, arguments, &block)
      @names = names.map(&:to_s)
      self.args = (arguments || "ARG")
      
      @desc  = desc
      @block = block
    end
    
    def args=(val)
      case val
      when String
        if val[-3..-1] == "..."
          @args = {:type => :splat, :base_name => val[0..-4]}
        
        else
          @args = {:type => :list, :arguments => []}
          val.split(' ').each do |arg|
            optional = false
            if arg[0] == "["
              optional = true
              arg = arg[1..-2]
            end

            @args[:arguments] << {:name => arg, :optional => optional}
          end
        end
      when Range
        @args = {:type => :range, :range => val}
      when Array
        @args = {:type => :choice, :items => val}
      end
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
      when :choice
        unless @args[:items].map{|i| i.to_s}.include?(args[0])
          raise InvalidArgument.new(args)
        end
      when :range
        unless @args[:range].to_a.map {|i| i.to_s}.include?(args[0])
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
    
    def args_to_string
      case @args[:type]
      when :list
        r = []
        @args[:arguments].each do |arg|
          if arg[:optional]
            r << "[" + arg[:name] + "]"
          else
            r << "<" + arg[:name] + ">"
          end
        end
        r.join(' ')
      when :choice, :range
        ""
      when :splat
        "<#{@args[:base_name]}1> ..."
      end
    end
    
    def options_to_string
      case @args[:type]
      when :list, :splat
        ''
      when :choice
        '(' + @args[:items].join(', ') + ')'
      when :range
        '(' + @args[:range].to_s + ')'
      end
    end
    
    def to_h
      {
        'names'   => names_to_strings,
        'desc'    => @desc,
        'args'    => args_to_string,
        'options' => options_to_string
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