module Clive

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
  #   # the argument is saved into the hash as a Date object.
  #
  class Option

    extend Type::Lookup

    attr_reader :names, :opts, :args, :description
    alias_method :desc, :description

    # @param short [Symbol, #to_sym]
    #   Short name (single character) for this option.
    #
    # @param long [Symbol, #to_sym]
    #   Long name (multiple characters) for this option.
    #
    # @param description [String]
    #   Description of the option.
    #
    # @param opts [Hash]
    # @option opts [true, false] :head
    #   If option should be at top of help listing
    # @option opts [true, false] :tail
    #   If option should be at bottom of help listing
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
      @names = names.sort_by(&:size)
      @description  = description
      @block = block

      @opts, hash = sort_opts(opts)

      hash  = args_to_hash(hash)
      hash  = infer_args(hash)
      @args = optify(hash)
    end
<<<<<<< HEAD
    
    # Calls the block.
    def run(*args)
      @block.call
=======

    def pad(arr, max)
      if arr.size < max
        (max - arr.size).times { arr << nil }
      end
      arr
>>>>>>> master
    end


    # @return [Array[Hash]] Two hashes.
    #  The first hash contains all options relevent to the Option, to be stored
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


    def args_to_hash(opts)
      withins = []
      if opts.has_key?(:withins)
        if opts[:withins].respond_to?(:[]) && opts[:withins][0].is_a?(Array)
          withins = opts[:withins]
        else
          withins = [opts[:withins]]
        end
      end

      a = {
        :types       => Array(opts[:types])       || [],
        :matches     => Array(opts[:matches])     || [],
        :withins     => withins,
        :defaults    => Array(opts[:defaults])    || [],
        :constraints => Array(opts[:constraints]) || []
      }

      max = a.values.map(&:size).max

      a = Hash[ a.map {|k,v|
        [k, pad(v, max)]
      }]

      b = []
      max.times {|i|
        c = {}
        {
          :types => :type,
          :matches => :match,
          :withins => :within,
          :defaults => :default,
          :constraints => :constaint
        }.each do |plural, single|
          c[single] = a[plural][i] if a[plural][i]
        end

        b << c
      }

      return b unless opts[:args]

      optional = false
      cancelled_optional = false
      opts[:args].split(' ').zip(b).map {|arg, opts|
        if cancelled_optional
          optional = false
          cancelled_optional = false
        end

        if arg[-1] == ']'
          cancelled_optional = true
        end

        if arg[0] == '['
          optional = true
        elsif arg[0] == '<'
          # okay
        else
          # problem
          raise InvalidArgumentString
        end

        opts ||= {}
        {:name => arg.gsub(/^\[?\<|\>\]?$/, ''), :optional => optional}.merge(opts)
      }
    end

    def optify(hash)
      hash.map do |opts|
        Argument.new(opts[:name] || 'arg', *opts.without(:name))
      end
    end

    def infer_args(opts)
      opts.map do |hash|
        if hash.has_key?(:default)
          hash.merge({:name => 'arg', :optional => true})
        elsif hash.has_key?(:within)
          hash.merge({:name => 'choice'})
        elsif hash.has_any_key?(:type, :match, :constraint)
          hash.merge({:name => 'arg'})
        else
          hash
        end
      end
    end

    def do_opts(opts)
      opts[:as]           = Array(opts[:as]) || []
      opts[:match]        = Array(opts[:match]) || []
      opts[:in]           = [opts[:in]] if opts[:in].is_a?(Array) && !opts[:in][0].is_a?(Array)
      opts[:in]         ||= []
      opts[:default]      = Array(opts[:default]) || []
      opts[:constraint]   = Array(opts[:constraint])
      opts
    end

    # If size is 1, then returns [name], otherwise appends a number starting at 1 after each.
    def string_with_numbers(name, size)
      if size > 1
        (1..size).map {|i| name + i.to_s }
      else
        [name]
      end
    end

    def short
      @names.find {|i| i.size == 1 }
    end

    def long
      @names.find {|i| i.size > 1 }
    end

    def name
      names.last
    end

    def to_s
      r = ""
      r << "-#{short}" if short
      r << ", "        if short && long
      r << "--#{long}" if long
      r
    end

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

    # Maps the +args+ to this options arguments
    # @return [::Hash{Argument=>Object}]
    def map_args(args)
      ::Hash[@args.zip(filled_args(args)).find_all {|a,e| a.possible?(e) }]
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
        Hash[ map_args(args).map {|k,v| [k.name, v]} ]
      end

      RunClass._run(mapped_args, state, @block)
    end


    def boolean?
      args.size == 1 && args.first.type == Clive::Type::Boolean
    end

    def min_args
      if boolean?
        0
      else
        @args.reject {|i| i.optional? }.size
      end
    end

    def max_args
      if boolean?
        0
      else
        @args.size
      end
    end

    def possible?(list)
      @args.zip(list).all? {|arg,item| item ? arg.possible?(item) : true } && list.size <= max_args
    end

    def valid?(list)
      if boolean?
        list == [true] || list == [false]
      else
        list.size >= min_args && possible?(list)
      end
    end

    def valid_arg_list(list)
      match = @args.map {|i| !i.optional? }
      list = list.dup
      diff = list.size - match.find_all {|i| i == true }.size

      result = []
      match.each_index do |i|
        curr = match[i]
        result << if curr
          list.shift
        elsif diff > 0
          diff -= 1
          list.shift
        else
          nil
        end
      end

      # Use defaults if necessary and coerce
      result.zip(@args).map {|r,a| r ? a.coerce(r) : a.coerce(a.default) }
    end

    def name
      @names.find {|i| i.size > 1 }
    end

    def args
      @args
    end


    puts "#{__FILE__}:#{__LINE__} remove these methods"
    def option?
      true
    end

    def command?
      false
    end

  end

  # Class for running in
  class RunClass
    class << self

      def _run(args, state, fn)
        @args = args
        @state = state
        return unless fn
        if fn.arity > 0
          instance_exec(*args.values, &fn)
        else
          instance_exec &fn
        end
      end

      def get(key)
        @state[key]
      end

      def set(key, value)
        @state[key] = value
      end

      def method_missing(sym, *args)
        if @args.has_key?(sym)
          @args[sym]
        else
          super
        end
      end

    end
  end

end
