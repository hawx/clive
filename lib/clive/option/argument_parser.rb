module Clive

  class Option
  
    class ArgumentParser
    
      attr_reader :opts, :args
    
      # @param [Hash]
      def initialize(options, opt_keys)      
        @opt_keys = opt_keys
        @arg_keys = Clive::Arguments::Parser::KEYS
      
        @opts, hash = sort_opts(options)
        @args = Arguments.create(hash)
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
      
    end
  end
end
