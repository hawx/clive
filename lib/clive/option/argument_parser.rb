module Clive
  class Option
  
    class ArgumentParser
    
      attr_reader :opts, :args
    
      # @param [Hash]
      def initialize(opt_keys, arg_keys, options)
        @opt_keys = opt_keys
        @arg_keys = arg_keys
      
        opts, hash = sort_opts(options)
        args = args_to_hash(hash)
        args = infer_args(args)
        
        args.map! {|arg| Clive::Argument.new(arg[:name] || 'arg', arg.reject {|k,v| k==:name }) }
        @opts = opts
        @args = ArgumentList.new(args)
      end
      
      def to_a
        [@opts, @args]
      end
      
      protected
      
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
        [get_and_rename_hash(hash, @opt_keys), get_and_rename_hash(hash, @arg_keys)]
      end
      
      # @param hash [Hash]
      # @param keys [Hash]
      def get_and_rename_hash(hash, keys)
        Hash[ hash.find_all {|k,v| keys.include?(k) } ].inject({}) do |hsh, (k,v)|
          if keys.include?(k)
            if keys.respond_to?(:key?)
              hsh[keys[k]] = v
            else
              hsh[k] = v
            end
            hsh
          end
        end
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
      
      # This turns the arguments string and other options into a nicely formatted 
      # hash.
      #
      # @return [Hash]
      def args_to_hash(opts)
        withins = []
        # Normalise withins separately as it will usually be an Array.
        if opts.has_key?(:within)
          unless opts[:within].respond_to?(:[]) && opts[:within][0].is_a?(Array)
            opts[:within] = [opts[:within]]
          end
        end
        
        # Make everything an Array
        multiple = Hash[ opts.map {|k,v| [k, Array(v)] } ]
        
        # Find the largest Array...
        max = multiple.values.map(&:size).max || 0
        
        # Split into an array of hashes, with each hash for each item of the previous
        # Arrays.
        # ie. go from {:as => [b, c], ...}
        #          to [{:a => b, ...}, {:a => c, ...}, ...]
        #
        singles = multiple.map {|k, arr| pad(arr, max).map {|i| [k, i] } }.
                            transpose.
                            map {|i| Hash[ i.reject {|a,b| b == nil || a == :arg } ] }
 
        # If no arg string to parse return now.
        return singles unless opts[:arg]
  
        optional = false
        cancelled_optional = false
        # Parse the argument string and merge in previous options from +singles+.
        opts[:arg].split(' ').zip(singles).map {|arg, opts|
          if cancelled_optional
            optional = false
            cancelled_optional = false
          end
  
          cancelled_optional = true if arg[-1..-1] == ']'
  
          if arg[0..0] == '['
            optional = true
          elsif arg[0..0] != '<'
            raise InvalidArgumentString
          end
          
          {:name => clean(arg), :optional => optional}.merge(opts || {})
        }
      end
      
      def clean(name)
        name.gsub(/^\[?\<|\>\]?$/, '')
      end
      
      # Infer arguments that haven't been explicitly defined by name. This allows you
      # to just say "it" should be within the range +1..5+ and have an argument 
      # created without having to pass +:arg => '<choice>'+.
      def infer_args(opts)
        opts.map do |hash|
          if hash.has_key?(:name)
            hash
          else
            if [:type, :match, :constraint, :within, :default].all? {|key| hash.has_key?(key) }
              hash.merge!({:name => 'arg'})
            end
            hash.merge!({:optional => true}) if hash.has_key?(:default) && !hash.has_key?(:optional)
          
            hash
          end
        end
      end
    
    end
  end
end
