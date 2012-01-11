class Clive

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
  #   bool :F, :force     # OR  opt :F, :force, boolean: true
  #   # call with
  #   #   -F or --force  to set to true
  #   #   --no-force     to set to false
  #
  #   opt :email, arg: '<a@b.c>', match: /\w+@\w+\.\w+/
  #   # call with
  #   #   --email john@doe.com
  #   # but not
  #   #   --email not-an-email-address
  #   # which raises Clive::Parser::MissingArgumentError
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
  # Since options can take multiple arguments (<a> <b> <c>) it is possible to
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
  #   # be used.
  #
  class Option

    class InvalidNamesError < Error
      reason '#1'
    end

    extend Type::Lookup

    # @return [Array<Symbol>] List of names this Option can be called
    attr_reader :names
    # @return [Hash{Symbol=>Object}] Options passed to {#initialize} using
    #   defaults when not given
    attr_reader :opts
    # @return [Arguments] List of arguments this Option can take when ran
    attr_reader :args
    # @return [String] Description of the Option
    attr_reader :description

    # Default values to use for +@opts+. These are also the options that
    # Option takes, see {#initialize} for details.
    DEFAULTS = {
      :boolean => false,
      :group   => nil,
      :head    => false,
      :tail    => false,
      :runner  => Clive::Option::Runner
    }

    # @param names [Array<Symbol>] Names for this option
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

      # @return [Symbol, nil] Short name from the names (ie. +:a+)
      def @names.short
        find {|i| i.to_s.size == 1 }
      end

      # @return [Symbol, nil] Long name from the names (ie. +:abc+)
      def @names.long
        find {|i| i.to_s.size > 1 }
      end

      @description  = description
      @block = block

      @args = Arguments.create( get_subhash(opts, Arguments::Parser::KEYS.keys) )
      @opts = DEFAULTS.merge( get_subhash(opts, DEFAULTS.keys) || {} )
    end

    # @return [Symbol] The longest name given
    def name
      @names.long || @names.short
    end

    # @return [String] String representaion of the Option
    def to_s
      r = ""
      r << "-#{@names.short}" if @names.short
      if @names.long
        r << ", " if @names.short
        r << "--"
        r << "[no-]" if @opts[:boolean] == true
        r << @names.long.to_s.gsub('_', '-')
      end

      r
    end

    # @return [String]
    def inspect
      "#<#{self.class} #{to_s}>"
    end

    # @return Whether a block was given.
    def block?
      @block != nil
    end

    # Runs the Option's block with the current state and arguments passed.
    #
    # @param state [Hash] Local state for parser, this may be modified!
    # @param args [Array] Arguments for the block which is run
    # @param scope [Command] Scope of the state to use
    # @return [Hash] the state which may have been modified!
    def run(state, args=[], scope=nil)
      mapped_args = if @opts[:boolean] == true
        [[:truth, args.first]]
      else
        @args.zip(args).map {|k,v| [k.name, v] }
      end

      if block?
        if scope
          state = @opts[:runner]._run(mapped_args, state[scope.name], @block)
        else
          state = @opts[:runner]._run(mapped_args, state, @block)
        end
      else
        state = set_state(state, args, scope)
      end

      state
    end

    include Comparable

    # Compare based on the size of {#name}, makes sure tails go to the bottom
    # and heads go to the top. If both are head or tail then sorts based on the
    # names.
    #
    # @param other [Option] Option to compare with
    # @return [Integer] Either -1, 0 or 1
    def <=>(other)
      if (opts[:tail] && !other.opts[:tail]) || (other.opts[:head] && !opts[:head])
        1
      elsif (other.opts[:tail] && !opts[:tail]) || (opts[:head] && !other.opts[:head])
        -1
      else
        self.name.to_s <=> other.name.to_s
      end
    end


    private

    # Sets a value in the state.
    #
    # @param state [#store, #[]]
    # @param args [Array]
    # @param scope [Symbol, nil]
    def set_state(state, args, scope=nil)
      args = (@args.max <= 1 ? args[0] : args)

      if scope
        state[scope.name].store [@names.long, @names.short].compact, args
      else
        state.store [@names.long, @names.short].compact, args
      end

      state
    end

    # @param hash [Hash]
    # @param keys [Array]
    def get_subhash(hash, keys)
      Hash[ hash.find_all {|k,v| keys.include?(k) } ]
    end

  end

end
