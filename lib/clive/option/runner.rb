class Clive

  # Methods for modifying a state object. Requires that the instance variable
  # +@state+ exists and that it responds to +#[]+, +#store+ and +#key?+.
  module StateActions

    # Gets the value for the key, returns nil if the key does not exist.
    #
    # @param key [Symbol]
    #
    # @example
    #   set :some_key, 1
    #   opt :get_some_key do
    #     puts get(:some_key)   #=> 1
    #   end
    #
    def get(key)
      @state[key]
    end

    # Gets the value for the key, raises an error if the key does not exist.
    #
    # @param key [Symbol]
    # @raise [KeyError]
    def get!(key)
      if has?(key)
        get(key)
      else
        raise KeyError, "key not found: #{key}"
      end
    end

    # Sets the key to the value given.
    #
    # @param key [Symbol]
    # @param value [Object]
    #
    # @example
    #   opt :set_some_key do
    #     set :some_key, 1
    #   end
    #
    def set(key, value)
      @state.store key, value
    end

    # @overload update(key, method, *args)
    #   Update the value for +key+ using the +method+ which is passed +args+
    #   @param key [Symbol]
    #   @param method [Symbol]
    #   @param args [Object]
    #
    #   @example
    #     set :list, []
    #     opt :add, arg: '<item>' do
    #       update :list, :<<, item
    #     end
    #
    # @overload update(key, &block)
    #   Update the value for +key+ with a block
    #   @param key [Symbol]
    #
    #   @example
    #     set :list, []
    #     opt :add, arg: '<item>' do
    #       update(:list) {|l| l << item }
    #     end
    #
    def update(*args)
      if block_given?
        key = args.first
        set key, yield(get(key))
      elsif args.size > 1
        key, method = args.shift, args.shift
        set key, get(key).send(method, *args)
      else
        raise ArgumentError, "wrong number of arguments (#{args.size} for 2)"
      end
    end

    # @param key [Symbol]
    # @return State has +key+?
    #
    # @example
    #   # test.rb
    #   set :some_key, 1
    #   opt(:has_some_key)  { puts has?(:some_key) }
    #   opt(:has_other_key) { puts has?(:other_key) }
    #
    #   # ./test.rb --has-some-key   #=> true
    #   # ./test.rb --has-other-key  #=> false
    #
    def has?(key)
      @state.key? key
    end

  end

  class Option

    # Runner is a class which is used for executing blocks given to Options and
    # Commands. It allows you to inside blocks;
    # - reference arguments by name (instead of using block params)
    # - get values from the state hash
    # - set value to the state hash
    # - update values in the state hash
    #
    # @example Referencing Arguments by Name
    #
    #   opt :size, args: '<height> <width>', as: [Float, Float] do # no params!
    #     puts "Area = #{height} * #{width} = #{height * width}"
    #   end
    #
    # @example Getting Values from State
    #
    #   command :new, arg: '<dir>' do
    #
    #     opt :type, in: %w(post page blog)
    #
    #     action do
    #       type = has?(:type) ? get(:type) : 'page'
    #       puts "Creating #{type} in #{dir}!"
    #     end
    #
    #   end
    #
    # @example Setting Values to State
    #
    #   opt :set, arg: '<key> <value>', as: [Symbol, Object] do
    #     set key, value
    #   end
    #
    # @example Updating Values in State
    #
    #   opt :modify, arg: '<key> <sym> [<args>]', as: [Symbol, Symbol, Array] do
    #     update key, sym, *args
    #   end
    #
    #
    class Runner
      class << self

        # @param args [Array[Symbol,Object]]
        #   An array is used because with 1.8.7 a hash has unpredictable
        #   ordering of keys, this means an array is the only way I can be
        #   sure that the arguments are in order.
        # @param state [Hash{Symbol=>Object}]
        # @param fn [Proc]
        def _run(args, state, fn)
          return unless fn
          # order of this doesn't matter as it will just be accessed by key
          @args = Hash[args]
          @state = state

          if fn.arity > 0
            # Remember to use the ordered array version
            instance_exec(*args.map {|i| i.last }, &fn)
          else
            instance_exec(&fn)
          end

          @state
        end

        include Clive::StateActions

        # Allows arguments passed in to be referenced directly by name.
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
end
