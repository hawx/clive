# can't autoload time as the constant is already defined
require 'time'
autoload :Pathname, 'pathname'

class Clive
  class Type

    # Basic object, all arguments are valid and will simply return
    # themselves.
    class Object < Type

      # Test the value to see if it is a valid value for this Tyoe.
      # @param arg [String] The value to be tested
      def valid?(arg)
        true
      end

      # Cast the arg (String) to the correct type.
      # @param arg [String] The value to be cast
      def typecast(arg)
        arg
      end
    end

    # String will accept any argument which is not +nil+ and will
    # return the argument with #to_s called on it.
    class String < Object
      refute :nil?
      cast   :to_s
    end

    # Symbol will accept and argument which is not +nil+ and will
    # return the argument with #to_sym called on it.
    class Symbol < Object
      refute :nil?
      cast   :to_sym
    end

    # Integer will match anything that float matches, but will
    # return an integer. If you need something that only matches
    # integer values properly use {StrictInteger}.
    class Integer < Object
      match /^[-+]?\d*\.?\d+([eE][-+]?\d+)?$/
      cast  :to_i
    end

    # StrictInteger only matches strings that look like integers,
    # it returns Integers.
    # @see Integer
    class StrictInteger < Object
      match /^[-+]?\d+([eE][-+]?\d+)?$/
      cast  :to_i
    end

    # Binary matches any binary number which may or may not have a "0b" prefix
    # and returns the number as an Integer.
    class Binary < Object
      match /^[-+]?(0b)?[01]*$/i
      cast  :to_i, 2
    end

    # Octal matches any octal number which may (or may not) be prefixed with "0"
    # or "0o" (or even "0O") so 25, 025, 0o25 and 0O25 are all valid and will
    # give the same result, the Integer 21.
    class Octal < Object
      match /^[-+]?(0o?)?[0-7]*$/i
      cast  :to_i, 8
    end

    # Hexadecimal matches any hexadecimal number which may or may not have a
    # "0x" prefix, it returns the number as an Integer.
    class Hexadecimal < Object
      match /^[-+]?(0x)?[0-9a-f]*$/i
      cast  :to_i, 16
    end

    class Float < Object
      match /^[-+]?\d*\.?\d+([eE][-+]?\d+)?$/
      cast  :to_f
    end

    # Boolean will accept 'true', 't', 'yes', 'y' or 'on' as +true+ and
    # 'false', 'f', 'no', 'n' or 'off' as +false+.
    class Boolean < Object
      TRUE_VALUES  = %w(true t yes y on)
      FALSE_VALUES = %w(false f no n off)

      def valid?(arg)
        (TRUE_VALUES + FALSE_VALUES).include? arg
      end

      def typecast(arg)
        case arg
          when *TRUE_VALUES  then true
          when *FALSE_VALUES then false
        end
      end
    end

    class Pathname < Object
      refute :nil?

      def typecast(arg)
        ::Pathname.new arg
      end
    end

    # Range accepts 'a..b', 'a...b' which behave as in ruby and
    # 'a-b' which behaves like 'a..b'. It returns the correct
    # Range object.
    class Range < Object
      match /^(\w+\.\.\.?\w+|\w+\-\w+)$/

      def typecast(arg)
        if arg.include?('...')
          a,b = arg.split('...')
          ::Range.new a, b, true
        elsif arg.include?('..')
          a,b = arg.split('..')
          ::Range.new a, b, false
        else
          a,b = arg.split('-')
          ::Range.new a, b, false
        end
      end
    end

    # Array accepts a list of arguments separated by a comma, no
    # spaces are allowed. It returns an array of the elements.
    class Array < Object
      match /^(.+,)*.+[^,]$/
      cast  :split, ','
    end

    # Time accepts any value which can be parsed by {::Time.parse},
    # it returns the correct {::Time} object.
    class Time < Object
      def valid?(arg)
        ::Time.parse arg
        true
      rescue
        false
      end

      def typecast(arg)
        ::Time.parse arg
      end
    end

    class Regexp < Object
      match /^\/.*?\/[imxou]*$/

      OPTS = {
        'x' => ::Regexp::EXTENDED,
        'i' => ::Regexp::IGNORECASE,
        'm' => ::Regexp::MULTILINE
      }

      def typecast(arg)
        parts = arg.split('/')
        parts << '' if parts.size < 3

        _, arg, mods = parts
        mods = mods.split('').map {|a| OPTS[a] }.inject{|a,e| a | e }

        ::Regexp.new arg, mods
      end
    end

  end
end
