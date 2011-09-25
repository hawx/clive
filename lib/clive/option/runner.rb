module Clive
  class Option
  
    class Runner
      class << self
  
        # @param args [Array[Symbol,Object]]
        #   An array is used because with 1.8.7 a hash has unpredictable
        #   ordering of keys, this means an array is the only way I can be
        #   sure that the arguments are in order.
        # @param state [Hash{Symbol=>Object}]
        # @param fn [Proc]
        def _run(args, state, fn)
          # order of this doesn't matter as it will just be accessed by key
          @args = Hash[args] 
          @state = state
          return unless fn
          if fn.arity > 0
            # Remember to use the ordered array version
            instance_exec(*args.map {|i| i.last }, &fn)
          else
            instance_exec(&fn)
          end
          @state
        end
        
        # @param key [Symbol]
        def get(key)
          @state[key]
        end
        
        # @param key [Symbol]
        # @param value [Object]
        def set(key, value)
          @state[key] = value
        end
        
        # @overload update(key, method, *args)
        #   @param key [Symbol]
        #   @param method [Symbol]
        #   @param args [Object]
        #
        # @example With method name
        #
        #   opt :add, arg: '<item>' do
        #     set(:list, []) unless has?(:list)
        #     update :list, :<<, item
        #   end
        #
        # @overload update(key, &block)
        #   @param key [Symbol]
        #
        # @example With block
        #
        #   opt :add, arg: '<item>' do
        #     update(:list) {|l| (l ||= []) << item }
        #   end
        #  
        def update(*args)
          if block_given?
            key = args.first
            set(key, yield(get(key)))
          elsif args.size > 1
            key, method = args.shift, args.shift
            r = get(key).send(method, *args)
            set(key, r)
          else
            raise ArgumentError, "wrong number of arguments (#{args.size} for 2)"
          end
        end
        
        # @param key [Symbol]
        # @return State has key?
        def has?(key)
          @state.has_key?(key)
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
end
