class Clive
  
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
    def initialize(*args, &block)
      @names = []
      @args  = []
      
      # Need to be able to make each arg_name optional or not
      # and allow for type in future
      args.each do |i|
        if i.is_a? String
          if i =~ /\A(([A-Z0-9\[\]]+)\s?)+\Z/
            i.split(' ').each do |arg|
              type = String
              if arg[0] == "["
                @args << {
                  :name => arg[1..arg.length-2], 
                  :optional => true,
                  :type => type
                }
              else
                @args << {
                  :name => arg, 
                  :optional => false, 
                  :type => type
                }
              end
            end
          else
            @desc = i
          end
        else
          if i.class == Symbol
            @names << i.to_s 
          else
            @args = i
          end
        end
      end
      
      if @args == []
        @args = [{:name => "ARG", :optional => false, :type => String}]
      end

      @block = block
    end
    
    # Runs the block that was given with an argument
    #
    # @param [Array] args arguments to pass to the block
    # @raise [InvalidArgument] only if +args+ is an array of acceptable inputs
    #   and a match is not found.
    def run(args)
      if @args[0].is_a? Hash
        args = Clive::Array.new(@args.collect {|i| !i[:optional]}).optimise_fill(args)
      else # list
        unless @args.include? args[0]
          raise InvalidArgument.new(args)
        end
      end
      @block.call(*args)
    end
    
    # @param [Boolean] optional whether to include optional arguments
    # @return [Integer] number of arguments this takes
    def arg_num(optional)
      if @args[0].is_a? Hash
        @args.find_all {|i| i[:optional] == optional }.size
      else
        1
      end
    end
    
    # @return [String] summary for help
    def summary(width=30, prepend=5)
      n = names_to_strings.join(', ')
      a = nil
      if @args[0].is_a? Hash
        a = @args.map {|i| i[:name]}.join(' ')
        if @optional
          n << " [#{a}]"
        else
          n << " #{a}"
        end
      else
        n << " {" << @args.join(', ') << "}"
      end

      spaces = width-n.length
      spaces = 1 if spaces < 1
      s = spaces(spaces)
      p = spaces(prepend)
      "#{p}#{n}#{s}#{@desc}"
    end
    
  end
end