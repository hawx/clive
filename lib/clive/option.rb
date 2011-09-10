module Clive
  
  # Raised when the argument string passed to {Option} is wrong.
  class InvalidArgumentString < RuntimeError; end

  # An option is called using either a long form +--opt+ or a short form +-o+
  # they can take arguments and these arguments can be restricted using various
  # parameters. 
  #
  #   opt :name, arg: '<first> [<middle>] <second>' do |f, m, s|
  #     # do something
  #   end
  #   # call with
  #   #  --name John Doe          to set; f='John', m=nil,      s='Doe'
  #   #  --name John Thomas Doe   to set; f='John', m='Thomas', s='Doe'
  #
  #   opt :F, :force, as: Boolean
  #   # call with
  #   #   -F or --force  to set to true
  #   #   --no-force     to set to false
  #
  #   opt :email, arg: '<a@b.c>', match: /\w+@\w+\.\w+/
  #   # call with
  #   #   --email john@doe.com
  #   # but not
  #   #   --email not-an-email-address
  #   # which gives raises Clive::Parser::MissingArgumentError
  #
  #   opt :fruit, arg: '<choice>', in: %w(apple pear banana)
  #   # here any argument not in the array passed with :in will raise an error
  #
  #   opt :start, arg: '<date>', as: Date
  #   # here any argument which can't be parsed as a Date will raise an error,
  #   # the argument is saved into the state hash as a Date object.
  #
  #   opt :five_letter_word, arg: '<word>', constraint: -> i { i.size == 5 }
  #   # this only accepts words of five letters by calling the proc given.
  #
  # Since options can take multiple arguments (+<a> <b> <c>+) it is possible to
  # use each of the constraints above for each argument. 
  #
  #   opt :worked, arg: '<from> [<to>]', as: [Date, Date]
  #   # This makes both <from> and <to> a Date
  #
  #   opt :fruits, arg: '<choice> <number>', in: [%w(apple pear banana), nil], as: [nil, Integer]
  #   # Here we extend the :fruit example from above to allow a number of fruit
  #   # to be picked. Note the use of nil in places where we want the default to
  #   # be used. Also for :in I didn't have to put the second nil as that is 
  #   # implied but it does make it clearer.
  #
  class Option

    extend Type::Lookup

    attr_reader :names, :opts, :args, :description
    alias_method :desc, :description

    # @param short [Symbol]
    #   Short name (single character) for this option.
    #
    # @param long [Symbol]
    #   Long name (multiple characters) for this option.
    #
    # @param description [String]
    #   Description of the option.
    #
    # @param opts [Hash]
    # @option opts [true, false] :head
    #   If option should be at top of help list
    # @option opts [true, false] :tail
    #   If option should be at bottom of help list
    # @option opts [String] :args
    #   Arguments that the option takes. See {Argument}.
    # @option opts [Type, Array[Type]] :as
    #   The class the argument(s) should be cast to. See {Type}.
    # @option opts [#match, Array[#match]] :match
    #   Regular expression that the argument(s) must match
    # @option opts [#include?, Array[#include?]] :in
    #   Collection that argument(s) must be in
    # @option opts :default
    #   Default value that is used if argument is not given
    #
    # @example
    #
    #   Option.new(
    #     [:N, :new],
    #     "Add a new thing",
    #     {:args => "<dir> [<size>]", :matches => [/^\//], :types => [nil, Integer]}
    #   )
    #
    def initialize(names=[], description="", opts={}, &block)
      raise "A name must be given for this Option"   if names.size == 0
      raise "Too many names passed to Option"        if names.size > 2
      raise "An option can only have one long name"  if names.find_all {|i| i.size > 1 }.size > 1
      raise "An option can only have one short name" if names.find_all {|i| i.size == 1 }.size > 1
    
      @names = names.sort
      @description  = description
      @block = block

      @opts, @args = do_options(opts)
    end
    
    # Short name for the option. (ie. +-a+)
    # @return [Symbol]
    def short
      @names.find {|i| i.size == 1 }
    end
    
    # Long name for the option. (ie. +--abc+)
    # @return [Symbol]
    def long
      @names.find {|i| i.size > 1 }
    end

    # The longest name available, as names are sorted by size the longest name
    # is the last in the Array.
    # @return [Symbol]
    def name
      names.last
    end

    # Pads +obj+ with +pad+ until it has size of +max+
    # @param obj [#size, #<<]
    # @param max [Integer]
    # @param pad [Object]
    def pad(obj, max, pad=nil)
      if obj.size < max
        (max - obj.size).times { obj << pad }
      end
      obj
    end
    
    # @return [Array<Hash,Array>]
    #  The first is a hash containing options for the Option.
    #  The second is an array of arguments the option takes.
    def do_options(opts)
      opts, hash = sort_opts(opts)
      args = infer_args(args_to_hash(hash))

      args.map! {|arg| Argument.new(arg[:name] || 'arg', arg.without(:name)) }
      
      [opts, args]
    end
    
    # This does two things, it splits the options hash into two hashes as explained
    # below. AND normalises the names of the hash keys meaning they can be accessed
    # easily.
    #
    # @return [Array[Hash]] Two hashes.
    #  The first hash contains all options relevant to the Option, to be stored
    #  in +@opts+.
    #  The second hash contains all options for building the arguments and should
    #  be used in the relevant methods.
    #  Hash keys for the returned hashes will be mapped to standard names from
    #  common variations.
    def sort_opts(hash)
      arg_keys = {
        :args        => [:arg],
        :types       => [:type, :kind, :as],
        :matches     => [:match],
        :withins     => [:within, :in],
        :defaults    => [:default],
        :constraints => [:constraint]
      }.flip

      opt_keys = {
        :head => [:head],
        :tail => [:tail]
      }.flip

      arg, opt = {}, {}
      hash.each do |k, v|
        if arg_keys.has_key?(k)
          arg[arg_keys[k]] = v
        elsif opt_keys.has_key?(k)
          opt[opt_keys[k]] = v
        elsif arg_keys.has_value?(k)
          arg[k] = v
        elsif opt_keys.has_value?(k)
          opt[k] = v
        end
      end

      [opt, arg]
    end

    # This turns the arguments string and other options into a nicely formatted 
    # hash.
    def args_to_hash(opts)
      withins = []
      # Normalise withins separately as it will usually be an Array.
      if opts.has_key?(:withins)
        if opts[:withins].respond_to?(:[]) && opts[:withins][0].is_a?(Array)
          withins = opts[:withins]
        else
          withins = [opts[:withins]]
        end
      end
      
      # Make everything an Array
      multiple = {
        :types       => Array(opts[:types])       || [],
        :matches     => Array(opts[:matches])     || [],
        :withins     => withins,
        :defaults    => Array(opts[:defaults])    || [],
        :constraints => Array(opts[:constraints]) || []
      }
      
      # Find the largest Array...
      max = multiple.values.map(&:size).max
      
      singles = []
      # Split into an array of hashes, with each hash for each item of the previous
      # Arrays.
      # ie. go from {:as => [b, c], ...}
      #          to [{:a => b, ...}, {:a => c, ...}, ...]
      #
      max.times do |i|
        singles[i] = {}
        {
          :types => :type,
          :matches => :match,
          :withins => :within,
          :defaults => :default,
          :constraints => :constraint
        }.each do |plural, single|
          singles[i][single] = multiple[plural][i] if multiple[plural][i]
        end
      end
      
      # If no arg string to parse return now.
      return singles unless opts[:args]

      optional = false
      cancelled_optional = false
      # Parse the argument string and merge in previous options from +singles+.
      opts[:args].split(' ').zip(singles).map {|arg, opts|
        if cancelled_optional
          optional = false
          cancelled_optional = false
        end

        cancelled_optional = true if arg[-1] == ']'

        if arg[0] == '['
          optional = true
        elsif arg[0] != '<'
          raise InvalidArgumentString
        end
        
        {:name => arg.gsub(/^\[?\<|\>\]?$/, ''), :optional => optional}.merge(opts || {})
      }
    end
    
    # Infer arguments that haven't been explicitly defined by name. This allows you
    # to just say "it" should be within the range +1..5+ and have an argument 
    # created without having to pass +:arg => '<choice>'+.
    def infer_args(opts)
      opts.map do |hash|
        if hash.has_key?(:name)
          hash
        else
          if hash.has_any_key?(:type, :match, :constraint, :within, :default)
            hash.merge!({:name => 'arg'})
          end
          hash.merge!({:optional => true}) if hash.has_key?(:default) && !hash.has_key?(:optional)
        
          hash
        end
      end
    end

    # @return [String]
    def to_s
      r = ""
      r << "-#{short}"         if short
      if long
        r << ", "              if short
        r << "--"
        r << "[no-]"           if boolean?
        r << long.dashify
      end
      
      r
    end
  
    # @return [String]
    def inspect
      "#<#{self.class} #{to_s}>"
    end

    # @return [true, false] Whether this option should come first in the help
    def head?
      @opts[:head]
    end

    # @return [true, false] Whether this option should come last in the help
    def tail?
      @opts[:tail]
    end

    # @return [true, false] Whether a block was given.
    def block?
      @block != nil
    end

    # Puts the arguments in the correct places, with +nil+ where an optional
    # argument has not been given.
    def filled_args(args)
      diff = args.size - @args.reject {|i| i.optional? }.size

      @args.zip(args).map do |arg, real|
        if arg.optional?
          if diff > 0
            diff -= 1
            real
          else
            nil
          end
        else
          real
        end
      end
    end

    # @param state [Hash] Global state for parser, this may be modified!
    # @param args [Array] Arguments for the block which is run
    def run(state, args=[])
      mapped_args = if boolean?
         {:truth => args.first}
      else
        Hash[ zip_args(args).map {|k,v| [k.name, v] } ]
      end

      RunClass._run(mapped_args, state, @block)
    end

    # Whether this is a boolean option and can be called with a +--no+ prefix.
    def boolean?
      args.size == 1 && args.first.type == Clive::Type::Boolean
    end
    
    # @return [Integer] The minimum number of arguments that this option takes.
    def min_args
      if boolean?
        0
      else
        @args.reject {|i| i.optional? }.size
      end
    end

    # @return [Integer] The maximum number of arguments that this option takes.
    def max_args
      if boolean?
        0
      else
        @args.size
      end
    end

    # Whether the +list+ of found arguments could possibly be the arguments for
    # this option. This does not need to check the minimum length as the list
    # may not be completely built, this just checks it hasn't failed completely.
    def possible?(list)
      (
        @args.zip(list).all? {|arg,item| item ? arg.possible?(item) : true } ||
        zip_args(list).all? {|arg,item| item ? arg.possible?(item) : true }
      ) && list.size <= max_args
    end

    # Whether the +list+ of found arguments is valid to be the arguments for this
    # option. Here length is checked as we need to make sure enough arguments are
    # present.
    def valid?(list)
      if boolean?
        list == [true] || list == [false]
      else
        list.size >= min_args && possible?(list)
      end
    end
    
    def zip_args(list)
      @args.zip_to_pattern(list, @args.map {|i| !i.optional? })
    end

    # Given +list+ will fill blank spaces with +nil+ where appropriate then
    # coerces each argument and uses default values if necessary.
    def valid_arg_list(list)
      # Use defaults if necessary and coerce
      zip_args(list).map {|a,r| r ? a.coerce(r) : a.coerce(a.default) }
    end

    # The first half of the help string.
    # @return [String]
    def before_help_string
      b = to_s
      if @args != [] && !boolean?
        b << " " << @args.map {|i| i.to_s }.join(' ').gsub('] [', ' ')
      end
      b
    end
    
    # The second half of the help string.
    # @return [String]
    def after_help_string
      a = @description
      if args.size == 1
        a << " " << args.first.choice_str
      end
      a.strip!
      a
    end
    
    # Compare based on the size of {#name}, makes sure {#tail?}s go to the bottom
    # and {#head?}s go to the top. If both are {#head?} or {#tail?} then sorts
    # based on size.
    def <=>(other)
      if (tail? && !other.tail?) || (head? && !other.head?)
        1
      elsif (other.tail? && !tail?) || (other.head? && !head?)
        -1
      else
        self.name <=> other.name
      end
    end
    
  end

end
