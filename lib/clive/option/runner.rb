module Clive
  class Option
  
    class Runner
      class << self
  
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
end