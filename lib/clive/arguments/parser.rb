module Clive
  class Arguments
    class Parser
    
      # Raised when the argument string passed to {Option} is wrong.
      class InvalidArgumentStringError < Error
        reason 'Invalid argument string format: #1'
      end
      
      # Valid key names for creating arguments passed to Option#initialize and 
      # standard names to map them to.      
      KEYS = {
        :arg        => [:args],
        :type       => [:types, :kind, :as],
        :match      => [:matches],
        :within     => [:withins, :in],
        :default    => [:defaults],
        :constraint => [:constraints]
      }.inject({}) {|hsh, (k,v)|
        (v + [k]).each {|key|
          hsh[key] = k
        }
        hsh
      }
      
      # @param opts [Hash]
      def initialize(opts)
        @opts = normalise_key_names(opts, KEYS) || {}
      end
      
      # This turns the arguments string and other options into a nicely formatted 
      # hash.
      #
      # @return [Array<Hash>]
      def to_a
        opts = @opts
        
        # :within is weird. You will generally set it to an Array, but can use
        # anything which responds to #include?. Unfortunately that includes String
        # which for many reasons should be checked against. So new rules...
        #
        # opts[:within] = %w(a b c)
        # #=> opts[:within] = [%w(a b c)]
        #
        # opts[:within] = ['a', 'b', 'c']
        # #=> opts[:within] = [['a', 'b', 'c']]
        #
        # opts[:within] = <#include?>
        # #=> opts[:within] = [<#include?>]
        #
        # opts[:within] = [<#include?>]
        # #=> opts[:within] = [<#include?>]
        #
        # opts[:within] = '1'..'5'
        # #=> opts[:within] = ['1'..'5']
        #
        # opts[:type] = Integer
        # opts[:within] = 1..5
        # #=> opts[:within] = [1..5]
        #
        # opts[:type] = Integer
        # opts[:within] = [1..5, nil]
        # #=> opts[:within] = [1..5, nil]
        #
        if opts[:within].respond_to?(:[])
          if opts[:within].respond_to?(:include?)
            if opts[:within].all? {|o| ([String] << opts[:type]).flatten.uniq.compact.any? {|t| o.is_a?(t) } }
              opts[:within] = [opts[:within]].compact
            elsif opts[:within].any? {|o| o.respond_to?(:include?) }
              opts[:within] = opts[:within]
            else
              opts[:within] = [opts[:within]].compact
            end            
          end
        else
          opts[:within] = [opts[:within]].compact
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
        return infer_args(singles) unless opts[:arg]
        
        optional = false
        cancelled_optional = false
        # Parse the argument string and merge in previous options from +singles+.
        args = opts[:arg].split(' ').zip(singles).map do |arg, opts|
          if cancelled_optional
            optional = false
            cancelled_optional = false
          end
        
          cancelled_optional = true if arg[-1..-1] == ']'
        
          if arg[0..0] == '['
            optional = true
          elsif arg[0..0] != '<'
            raise InvalidArgumentStringError.new(opts[:arg])
          end
        
          {:name => clean(arg), :optional => optional}.merge(opts || {})
        end
        
        infer_args(args)
      end
      
      # @return [Array<Argument>]
      def to_args
        to_a.map! do |arg|
          Argument.new arg.delete(:name) || 'arg', arg
        end
      end
      
      private
      
      # Infer arguments that haven't been explicitly defined by name. This allows you
      # to just say "it" should be within the range +1..5+ and have an argument 
      # created without having to pass +:arg => '<choice>'+.
      def infer_args(opts)
        opts.map do |hash|
          if hash.has_key?(:name)
            hash
          else
            if [:type, :match, :constraint, :within, :default].any? {|key| hash.has_key?(key) }
              hash.merge!({:name => 'arg'})
            end
            hash.merge!({:optional => true}) if hash.has_key?(:default) && !hash.has_key?(:optional)
          
            hash
          end
        end
      end
      
      # @param opts [Hash] Hash to rename keys in
      # @param keys [Hash] Map of key names to desired key names
      #
      # @example
      #   
      #   normalise_key_names({:a => 1, :b => 2}, {:a => :b, :b => :c})
      #   #=> {:b => 1, :c => 2}
      #
      def normalise_key_names(opts, keys)
        opts.inject({}) do |hsh, (k,v)|
          hsh[keys[k]] = v if keys.has_key?(k)
          hsh
        end
      end
      
      def pad(obj, max, pd=nil)
        if obj.size < max
          (max - obj.size).times { obj << pd }
        end
        obj
      end
      
      # @param name [String]
      # @return [String] Argument name without sqaure or angle brackets
      def clean(name)
        name.gsub(/^\[?\<|\>\]?$/, '')
      end
      
    end
  end
end