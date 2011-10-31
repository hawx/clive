module Clive

  # An Argument represents an argument for an Option or Command, it can be optional
  # and can also be constricted by various other values see {#initialize}.
  class Argument
  
    # A class which always returns true when a method is called on it. You can
    # add new methods it will return true for by calling {.for}. This also 
    # returns a new instance. It is not possible to remove methods. But why 
    # would you want to?
    #
    # @example
    #   eg = AlwaysTrue.for(:a, :b, :c)
    #   eg.a          #=> true
    #   eg.b(1,2,3)   #=> true
    #   eg.c { 1 }    #=> true
    #   eg.d          #=> NoMethodError
    #
    class AlwaysTrue
      # @param syms [Symbol] Methods which should return true
      def self.for(*syms)
        syms.each do |sym|
          define_method(sym) {|*a| true }
        end
        new
      end
    end

    # An Argument will have these traits by default.
    DEFAULTS = {
      :optional   => false,
      :type       => Clive::Type::Object,
      :match      => Clive::Argument::AlwaysTrue.for(:match),
      :within     => Clive::Argument::AlwaysTrue.for(:include?),
      :default    => nil,
      :constraint => Clive::Argument::AlwaysTrue.for(:call)
    }

    attr_reader :name, :default, :type

    # A new instance of Argument.
    #
    # @param opts [Hash]
    #
    # @option opts [#to_sym] :name
    #   Name of the argument.
    #
    # @option opts [Boolean] :optional
    #   Whether this argument is optional. An optional argument does not have 
    #   to be given and will pass +nil+ to the block if not given.
    #
    # @option opts [Type] :type
    #   Type that the matching argument should be cast to. See {Type} and the 
    #   various subclasses for details. Each {Type} defines something that the
    #   argument must match in addition to the +:match+ argument given.
    #
    # @option opts [#match] :match
    #   Regular expression the argument must match.
    #
    # @option opts [#include?] :within
    #   Collection that the matching argument should be in. This will be checked
    #   against the string argument and the cast object (see +:type+). So for 
    #   instance if +:type+ is set to +Integer+ you can set +:within+ to be an array
    #   of integers, [1,2,3], or an array of strings, %w(1 2 3), and get the
    #   same result.
    #
    # @option opts :default
    #   Default value the argument takes. This is only set or used if the Option or
    #   Command is actually called.
    #
    # @option opts [#call, #to_proc] :constraint
    #   Proc which is passed the found argument and should return +true+ if the
    #   value is ok and false if not.
    #   If the object responds to #to_proc this will be called and the resulting
    #   Proc object saved for later use. This allows you to then pass method symbols.
    #
    # @example
    #
    #   Argument.new(:arg, :optional => true, :type => Integer, :constraint => :odd?)
    #
    def initialize(name, opts={})
      @name = name.to_sym

      opts[:constraint] = opts[:constraint].to_proc if opts[:constraint].respond_to?(:to_proc)
      opts = DEFAULTS.merge(opts)

      @optional   = opts[:optional]
      @type       = Type.find_class(opts[:type].to_s) rescue opts[:type]
      @match      = opts[:match]
      @within     = opts[:within]
      @default    = opts[:default]
      @constraint = opts[:constraint]
    end

    # @return Whether the argument is optional.
    def optional?
      @optional
    end

    # @return [String] String representation for the argument.
    def to_s
      optional? ? "[<#@name>]" : "<#@name>"
    end
    
    # @return [String] 
    #  Choices or range of choices that can be made, for the help string.
    def choice_str
      if @within
        case @within
        when Array
          '(' + @within.join(', ') + ')'
        when Range
          '(' + @within.to_s + ')'
        else
          ''
        end
      else
        ''
      end
    end

    def inspect
      r = [self.class, to_s]

      r << "type=#@type"             if @type
      r << "match=#@match"           if @match
      r << "within=#@within"         if @within
      r << "default=#@default"       if @default
      r << "constraint=#@constraint" if @constraint

      "#<#{r.join(' ')}>"
    end

    # Determines whether the object given (see @param note), can be this argument.
    # Checks whether it is valid based on the options passed to {#initialize}.
    #
    # @param obj [String,Object]
    #   This method will be called at least twice for each argument, the first
    #   time when testing for {Arguments#possible?} and then for {Argument#valid?}.
    #   When called in {Arguments#possible?} +obj+ will be passed as a string,
    #   for {Argument#valid?} though +obj+ will have been cast using {#coerce}
    #   to the correct type meaning this method must deal with both cases.
    #
    # @return Whether +obj+ could be this argument.
    #
    def possible?(obj)  
      if !@type.valid?(obj.to_s)
        return false
      end

      if !@match.match(obj.to_s)
        return false
      end
      
      if !(@within.include?(obj.to_s) || @within.include?(coerce(obj)))
        return false
      end
      
      begin
        return false unless @constraint.call(obj.to_s)
      rescue
        return false unless @constraint.call(coerce(obj))
      end

      true
    end

    # Converts the given String argument to the correct type determined by the
    # {Type} object passed.
    def coerce(str)
      return str unless str.is_a?(String)
      @type.typecast(str)
    end
  end
  
end
