class Clive
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
        multiple = to_arrays(@opts.dup)
        args = split_into_hashes(multiple)

        if @opts.has_key?(:arg)
          # Parse the argument string and merge in previous options from +singles+.
          args = parse_args_string(args, @opts[:arg])
        end

        infer_args(args)
      end

      # @return [Array<Argument>]
      def to_args
        to_a.map do |arg|
          Argument.new(arg.delete(:name) || 'arg', arg)
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
            check = [:type, :match, :constraint, :within, :default]
            if check.any? {|key| hash.has_key?(key) }
              hash.merge! :name => 'arg'
            end

            if hash.has_key?(:default) && !hash.has_key?(:optional)
              hash.merge! :optional => true
            end

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

      # Adds enough of +pd+ to +obj+ to make it have #size of +max+.
      #
      # @param obj [#size]
      # @param max [Integer]
      # @param pd  [Object]
      # @return [Object]
      def pad(obj, max, pd=nil)
        i = (max - obj.size)
        obj + [pd] * (i < 0 ? 0 : i)
      end

      # @param name [String]
      # @return [String] Argument name without sqaure or angle brackets
      def clean(name)
        name.tr '[<>]', ''
      end

      # @param hash [Hash<Symbol=>Object, Symbol=>Array>]
      # @return [Hash<Symbol=>Array>]
      def to_arrays(hash)
        # :within is weird. You will generally set it to an Array, but can use
        # anything which responds to #include?. Unfortunately that includes String
        # which for many reasons should be checked against. So new rules...
        #
        # hash[:within] = <#include?>
        # #=> hash[:within] = [<#include?>]
        #
        # hash[:within] = [<#include?>]
        # #=> hash[:within] = [<#include?>]
        #
        # hash[:within] = '1'..'5'
        # #=> hash[:within] = ['1'..'5']
        #
        # hash[:type] = Integer
        # hash[:within] = 1..5
        # #=> hash[:within] = [1..5]
        #
        # hash[:type] = Integer
        # hash[:within] = [1..5, nil]
        # #=> hash[:within] = [1..5, nil]
        #
        if hash[:within].respond_to?(:[]) && hash[:within].respond_to?(:include?)
          if hash[:within].all? {|o|
              ([String] << hash[:type]).flatten.uniq.compact.any? {|t|
                o.is_a?(t)
              }
            }
            hash[:within] = [hash[:within]].compact

          elsif hash[:within].any? {|o| o.respond_to?(:include?) }
            hash[:within] = hash[:within]

          else
            hash[:within] = [hash[:within]].compact
          end
        else
          hash[:within] = [hash[:within]].compact
        end

        # Make all the values Arrays
        Hash[ hash.map {|k,v| [k, Array(v)] } ]
      end

      # Splits a single hash of arrays into a single array of hashes.
      #
      # @example
      #
      #    hash = {:a => [:g, :h, :i], :b => [:x, :y]}
      #    split_into_hashes(hash)
      #    #=> [
      #    #  {:a => :b, :b => :x},
      #    #  {:a => :h, :b => :y},
      #    #  {:a => :i}
      #    # ]
      #
      def split_into_hashes(hash)
        # Find the largest Array...
        max = hash.values.map(&:size).max || 0

        hash.map {|k, arr| pad(arr, max).map {|i| [k, i] } }.
          transpose.
          map {|i| Hash[ i.reject {|a,b| b == nil || a == :arg } ] }
      end

      # Parses the string passed in as +:arg+. The string should have the
      # following format:
      #
      #   <arg-name> - Indicates a required argument called "arg-name"
      #   [...]      - Can surround one or more <arg> tokens and means they are
      #                optional, eg. "[<optional> <and-another>]"
      #
      # @param hash [Hash<Symbol=>Object>]
      # @param arg_str [String]
      def parse_args_string(hash, arg_str)
        optional = false
        cancelled_optional = false

        arg_str.split(' ').zip(hash).map do |arg, opts|
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
      end

    end
  end
end
