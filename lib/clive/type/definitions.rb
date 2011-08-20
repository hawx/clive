module Clive
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
    
    class Integer < Object
      match /\d+/
      cast  :to_i
    end
    
    class Float < Object
      match /^\d+(\.[\d]+){0,1}$/
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
    
    # Range accepts 'a..b', 'a...b' which behave as in ruby and
    # 'a-b' which behaves like 'a..b'. It returns the correct 
    # Range object.
    class Range < Object
      match /^(\w+\.\.\.?\w+|\w+\-\w+)$/
      
      def typecast(arg)
        if arg.include?('...')
          ::Range.new(*arg.split('...'), true)
        elsif arg.include?('..')
          ::Range.new(*arg.split('..'), false)
        else
          ::Range.new(*arg.split('-'), false)
        end
      end
    end
    
    # Array accepts a list of arguments separated by a comma, no
    # spaces are allowed. It returns an array of the elements.
    class Array < Object
      match /^(\w+,)*\w+$/
      
      def typecast(arg)
        arg.split(',')
      end
    end
    
    require 'time'
    # Time accepts any value which can be parsed by {::Time.parse},
    # it returns the correct {::Time} object.
    class Time < Object
      def valid?(arg)
        ::Time.parse(arg)
        true
      rescue
        false
      end
      
      def typecast(arg)
        ::Time.parse(arg)
      end
    end
  
  end
end