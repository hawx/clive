module Clive

  class InvalidArgumentString < RuntimeError; end

  class Option

    attr_reader :short, :long, :desc, :opts, :args
  
    # @param short [Symbol, #to_sym]
    #   Short name (single character) for this option
    # @param long [Symbol, #to_sym]
    #   Long name (multiple characters) for this option
    # @param desc [String]
    #   Description of the option
    # @param opts [Hash] Options for the option!
    #   @option opts [true, false] :head
    #     If option should be at top of help listing
    #   @option opts [true, false] :tail
    #     If option should be at bottom of help listing
    #   @option opts [String] :args
    #     Arguments that the option takes. See Argument.
    #   @option opts [#_coerce, Array[#_coerce]] :as
    #     The class the argument(s) should be cast to
    #   @option opts [#match, Array[#match]] :match
    #     Regular expression that the argument(s) must match
    #   @option opts [#include?, Array[#include?]] :in
    #     Collection that argument(s) must be in
    def initialize(short, long, desc="", opts={}, &block)
      @short = short.to_sym if short
      @long  = long.to_sym if long
      @desc  = desc
      @opts  = map_opts(opts)
      @block = block

      @args = parse_args(opts[:args], nextify(opts[:as]), nextify(opts[:match]), nextify(opts[:in]))
    end

    # Defines the #next method on the object, if the object is responds to #pop, #next 
    # will pop the last item until there is only one left, which it will then continue 
    # to return. Any other object will just return itself.
    #
    # @param obj [Object]
    # @return [#next]
    def nextify(obj)
      if obj.respond_to?(:pop)
        def obj.next
          if size > 1
            pop
          else
            first
          end
        end
      else
        def obj.next
          self
        end
      end
    end
    
    def head?
      @opts[:head]
    end
    
    def tail?
      @opts[:tail]
    end
    
    
    def map_opts(options)
      { :arg  => :args, :matches => :match, 
        :type => :as,   :from => :in
      }.each do |from, to|
        options[to] = options.delete(from) if options.has_key?(from)
      end
      options
    end
    
    # @param args [String]
    # @param types [Array[#_coerce, #_matches?], #next]
    # @param matches [Array[#match], #next]
    # @param withins [Array[#include?], #next]
    def parse_args(args, types=nextify(nil), matches=nextify(nil), withins=nextify(nil))
      return [] unless args
      
      args = args.split(' ')
      
      r = []
      optional = false           # keep track of optionality(?)
      cancelled_optional = false # keep track of whether optionality was changed
      
      args.each do |arg|
        name = ""
        
        if arg[-1] == "]"
          arg = arg[0..-2]
          cancelled_optional = true
        end
        
        if arg[0] == "["
          optional = true          
          if arg[1] == "<"
            name = arg[2..-2]
          else
            name = arg[1..-1]
          end
          
        elsif arg[0] == "<"
          name = arg[1..-2]
        else
          # problem
          raise InvalidArgumentString
        end
        
        r << Argument.new(name, optional, types.next, matches.next, withins.next)
        
        if cancelled_optional
          optional = false
        end
      end
      
      r
    end
    
    def requires_arguments?
      @args.reject {|i| i.optional? }.size > 0
    end
    
    # Maps the +args+ to this options arguments
    # @return [::Hash{Argument=>Object}]
    def map_args(args)
      filled = optimise_fill(args, @args.map {|i| !i.optional? })
      ::Hash[ @args.zip(filled) ]
    end
    
    # Attempts to fill the result with values from +input+, giving priority to 
    # true, then false. If insufficient input to fill all false will use nil.
    #
    # @param [Array] input array of values to fill +match+ with
    # @param [Array] match array of trues and falses which is the pattern to match
    # @return [Array] filled array
    #
    # @example
    #
    #   optimise_fill(["a", "b", "c"], [true, false, false, true])
    #   #=> ["a", "b", nil, "c"]
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
    
    # @param args [Array]
    def run(args=nil)
      if args
        if @o
          @o._run(Hash[ map_args(args).map {|k,v| [k.name, v]} ], @block)
        else
          @o = Class.new {
            def _run(a, f)
              @a = a
              if f.arity > 0
                instance_exec(a.values, &f)
              else
                instance_exec &f
              end
            end
            
            def method_missing(sym, *args)
              if @a.has_key?(sym)
                @a[sym]
              else
                super
              end
            end
          }.new
          
          run(args)
        end
        
      else
        @block.call
      end
    end
  
  end
end