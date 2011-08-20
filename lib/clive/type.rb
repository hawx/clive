module Clive
  class Type
  
    # @param arg [::String]
    def valid?(arg)
      false
    end
    
    # @param arg [::String]
    def typecast(arg)
      nil
    end
    
    class << self
    
      # Find the class for +name+.
      # @param name [::String]
      def find_class(name)
        name = name.split('::').last
        const_get(name) if const_defined?(name)
      end
    
      # Shorthand to define #valid? for subclasses of {Type}, pass a
      # regular expression that should be matched or a symbol for a
      # method which will be called on the argument that returns either
      # true (valid) or false (invalid).
      #
      # @param other [#to_proc, Regexp]
      #
      # @example With a regular expression
      #
      #   class YesNo < Type
      #     match /yes|no/
      #     # ...
      #   end
      #
      # @example With a method symbol
      #
      #   class String
      #     def five?
      #       size == 5
      #     end
      #   end
      #
      #   class FiveChars < Type
      #     match :five?
      #     # ...
      #   end
      #       
      def match(other)
        if other.respond_to?(:to_proc)
          @valid = other.to_proc
        else
          @valid = proc {|arg| other =~ arg }
        end
      end
      
      # Similar to {.match} but opposite so where {.match} would be valid
      # refute is invlid.
      #
      # @param other [#to_proc, Regexp]
      def refute(other)
        if other.respond_to?(:to_proc)
          @valid = proc {|arg| !arg.send(other) }
        else
          @valid = proc {|arg| other !~ arg }
        end
      end

      # Shorthand to define a method which is called on the string argument
      # to return the correct type.
      #
      # @param sym [Symbol]
      #
      # @example
      #
      #   class Symbol < Type
      #     # ...
      #     cast :to_sym
      #   end
      #
      def cast(sym)
        @cast = proc {|arg| arg.send(sym) }
      end
      
      # Checks whether the +arg+ passed is valid, if {.match} or {.refute}
      # have been called it uses the Proc created by them otherwise calls
      # #valid?.
      #
      # @param arg [::String]
      def valid?(arg)
        if @valid
          @valid.call(arg)
        else
          new.valid?(arg)
        end
      end
      
      # Casts the +arg+ to the correct type, if {.cast} has been called it
      # uses the proc created otherwise it calls #typecast.
      #
      # @param arg [::String]
      def typecast(arg)
        if @cast
          @cast.call(arg)
        else
          new.typecast(arg)
        end
      end
      
    end
    
  end  
end

require 'clive/type/definitions'
require 'clive/type/lookup'
