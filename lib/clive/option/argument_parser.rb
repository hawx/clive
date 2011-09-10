module Clive
  class Option
  
    # An Array of {Argument} instances.
    class ArgumentList < Array
    
      # List:  a b c d
      # Other: 1 2
      #
      # a and d are optional we want
      #    [a] [b 1] [c 2] [d]
      #
      # Check a against 1   => false
      # Check b against 1   => true
      #    Next item of other
      # Check c against 2   => true
      #    No more items therefore => false
      #
      #  [false, true, true, false]
      #
      # Fill bool array => [nil, 1, 2, nil]
      # Zip, etc...
      #
      #
      # Now Other: 1 2 3
      # And a and c match only even numbers
      # sim. b and d match only odd numbers
      # a and d still optional
      # 
      # Check a against 1  => false
      # Check b against 1  => true
      #   Next item of other
      # Check c against 2  => true
      #   Next item of other
      # Check d against 3  => true
      # 
      # this causes problems if we have another non-optional argument
      #
      # Same scenario:
      #
      #  diff = other.size - (args with optional.false?)  => 3 - 2 = 1
      #
      #  Check a against 1  => false
      #  Check b against 1  => true (mandatory so ok to add)
      #   Next item
      #  Check c against 2  => true (mandatory so ok to add)
      #   Next item
      #  Check d against 3  => true (optional but diff > 0 so ok to add)
      #   Diff -= 1
      #   End of List
      #   IT WORKED
      # 
      #
      
      def cool_zip(other)
        other = other.dup.compact
        # Find the number of 'spares'
        diff = other.size - find_all {|i| !i.optional? }.size
        r = []
        
        
        map do |arg|
          if arg.possible?(other.first)
            if arg.optional?
              if diff > 0
                [arg, other.shift]
              else
                [arg, nil]
              end
            else
              [arg, other.shift]
            end
          else
            [arg, nil]
          end
        end
      end

      def to_s
        map {|i| i.to_s }.join(' ').gsub('] [', ' ')
      end
    end
  
    class ArgumentParser
    
      attr_reader :opts, :args
      
      ARG_KEYS = {
        :args        => [:arg],
        :types       => [:type, :kind, :as],
        :matches     => [:match],
        :withins     => [:within, :in],
        :defaults    => [:default],
        :constraints => [:constraint]
      }.flip
      
      OPT_KEYS = {
        :head => [:head],
        :tail => [:tail]
      }.flip
      
      PLURAL_KEYS = {
        :args        => :arg,
        :types       => :type,
        :matches     => :match,
        :withins     => :within,
        :defaults    => :default,
        :constraints => :constraint
      }
    
      # @param [Hash]
      def initialize(options)      
        opts, hash = sort_opts(options)
        args = infer_args(args_to_hash(hash))
  
        args.map! {|arg| Clive::Argument.new(arg[:name] || 'arg', arg.without(:name)) }
        
        @opts = opts
        @args = ArgumentList.new(args)
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
        [get_and_rename_hash(hash, OPT_KEYS), get_and_rename_hash(hash, ARG_KEYS)]
      end
      
      # @param hash [Hash]
      # @param keys [Hash]
      def get_and_rename_hash(hash, keys)
        Hash[ hash.find_all {|k,v| keys.include?(k) } ].rename(keys)
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
      def args_to_hash(opts)
        withins = []
        # Normalise withins separately as it will usually be an Array.
        if opts.has_key?(:withins)
          unless opts[:withins].respond_to?(:[]) && opts[:withins][0].is_a?(Array)
            opts[:withins] = [opts[:withins]]
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
        singles = multiple.rename(PLURAL_KEYS)
                           .map {|k, arr| pad(arr, max).map {|i| [k, i] } }
                           .transpose
                           .map {|i| Hash[ i.reject {|a,b| b == nil || a == :arg } ] }
 
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
            if hash.has_any_key?(:type, :match, :constraint, :within, :default)
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
