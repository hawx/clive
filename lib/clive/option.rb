module Clive

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
  #   opt :F, :force, boolean: true
  #   # call with
  #   #   -F or --force  to set to true
  #   #   --no-force     to set to false
  #
  #   # OR
  #   bool :F, :force
  #   # which is equivelent to the above
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
  #   # the argument is saved into the state as a Date object.
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
  #   opt :fruits, arg: '<choice> <number>', 
  #                in: [%w(apple pear banana), nil], 
  #                as: [nil, Integer]
  #   # Here we extend the :fruit example from above to allow a number of fruit
  #   # to be picked. Note the use of nil in places where we want the default to
  #   # be used. Also for :in I didn't have to put the second nil as that is 
  #   # implied but it does make it clearer.
  #
  class Option
  
    class InvalidNamesError < Error
      reason '#1'
    end

    extend Type::Lookup

    attr_reader :names, :opts, :args, :description
    alias_method :desc, :description
    
    # Valid key names for options passed to Option#initialize.
    OPT_KEYS = [:head, :tail, :group, :boolean, :runner]
    
    DEFAULTS = {
      :runner => Clive::Option::Runner
    }

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
    # @option opts :group
    #   Name of the group this option belongs to
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
      @names = names.sort_by {|i| i.to_s.size }
      @description  = description
      @block = block
      
      @opts, @args = ArgumentParser.new(opts, OPT_KEYS).to_a
      @opts = DEFAULTS.merge(@opts || {})
    end
    
    # Short name for the option. (ie. +:a+)
    # @return [Symbol, nil]
    def short
      @names.find {|i| i.to_s.size == 1 }
    end
    
    # Long name for the option. (ie. +:abc+)
    # @return [Symbol, nil]
    def long
      @names.find {|i| i.to_s.size > 1 }
    end

    # The longest name available, as names are sorted by size the longest name
    # is the last in the Array.
    # @return [Symbol]
    def name
      names.last
    end
    
    # @return [String]
    def to_s
      r = ""
      r << "-#{short}" if short
      if long
        r << ", " if short
        r << "--"
        r << "[no-]" if boolean?
        r << long.to_s.gsub('_', '-')
      end
      
      r
    end
  
    # @return [String]
    def inspect
      "#<#{self.class} #{to_s}>"
    end

    # @return Whether this option should come first in the help
    def head?
      @opts[:head] == true
    end

    # @return Whether this option should come last in the help
    def tail?
      @opts[:tail] == true
    end

    # @return Whether this is a boolean option and can be called with a +no-+ prefix.
    def boolean?
      @opts[:boolean] == true
    end

    # @return Whether a block was given.
    def block?
      @block != nil
    end
    
    # @param state [Hash] Local state for parser, this may be modified!
    # @param args [Array] Arguments for the block which is run
    # @return [Hash] the state which may have been modified!
    #
    def run(state, args=[])
      mapped_args = if boolean?
        [[:truth, args.first]]
      else
        @args.zip(args).map {|k,v| [k.name, v] }
      end
      
      if block?
        @opts[:runner]._run(mapped_args, state, @block)
      else
        state = set_state(state, args)
      end
      
      state
    end
    
    # @return [Integer] The minimum number of arguments that this option takes.
    # @todo Remove
    def min_args
      if boolean?
        0
      else
        @args.min
      end
    end

    # @return [Integer] The maximum number of arguments that this option takes.
    # @todo Remove
    def max_args
      if boolean?
        0
      else
        @args.max
      end
    end

    # Whether the +list+ of found arguments could possibly be the arguments for
    # this option. This does not need to check the minimum length as the list
    # may not be completely built, this just checks it hasn't failed completely.
    def possible?(list)
      @args.possible?(list)
    end

    # Whether the +list+ of found arguments is valid to be the arguments for this
    # option. Here length is checked as we need to make sure enough arguments are
    # present.
    def valid?(list)
      if boolean?
        list == [true] || list == [false]
      else
        @args.valid?(list)
      end
    end
    
    # @todo Remove
    def valid_arg_list(list)
      @args.create_valid(list)
    end
    
    include Comparable
    
    # Compare based on the size of {#name}, makes sure {#tail?}s go to the bottom
    # and {#head?}s go to the top. If both are {#head?} or {#tail?} then sorts
    # based on size.
    def <=>(other)
      if (tail? && !other.tail?) || (other.head? && !head?)
        1
      elsif (other.tail? && !tail?) || (head? && !other.head?)
        -1
      else
        self.name.to_s <=> other.name.to_s
      end
    end
    
    
    private
    
    def set_state(state, args)
      state[name] = (max_args <= 1 ? args[0] : args)
      state
    end
    
  end

end
