module Clive
  class Option
  
    class Runner
      class << self
  
        # @param args [Hash{Symbol=>Object}]
        # @param state [Hash{Symbol=>Object}]
        # @param fn [Proc]
        def _run(args, state, fn)
          @args = args
          @state = state
          return unless fn
          if fn.arity > 0
            instance_exec(*args.values, &fn)
          else
            instance_exec(&fn)
          end
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
