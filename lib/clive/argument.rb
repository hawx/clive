module Clive

  # An Argument represents an argument for an Option or Command, it can be optional
  # and can also be constricted by various other values.
  class Argument
  
    # A class which always returns true when a method is called on it. It has
    # {.include?}, {.match} and {.call} because they are the methods used.
    # So really it isn't __always__ true!
    class AlwaysTrue
      # @return [TrueClass]
      def self.include?(arg)
        true
      end
      
      # @return [TrueClass]
      def self.match(arg)
        true
      end
      
      # @return [TrueClass]
      def self.call(arg)
        true
      end
    end

    # An Argument will have these traits by default.
    DEFAULTS = {
      :optional   => false,
      :type       => Object,
      :match      => AlwaysTrue,
      :within     => AlwaysTrue,
      :default    => nil,
      :constraint => AlwaysTrue
    }

    attr_reader :name, :default, :type

    # A new instance of Argument.
    #
    # @param opts [Hash]
    #
    # @option opts [#to_sym] :name
    #   Name of the argument.
    #
    # @option opts [true, false] :optional
    #   Whether this argument is optional. An optional argument does not have 
    #   to be given and will instead pass +nil+ to the block.
    #
    # @option opts [Type] :type
    #   Type that the matching argument should be cast to. See {Type} and the 
    #   various subclasses for details.
    #
    # @option opts [#match] :match
    #   Regular expression the argument must match.
    #
    # @option opts [#include?] :within
    #   Collection that the matching argument should be in. This will be checked
    #   against the string argument and the cast object (see +:type+).
    #
    # @option opts :default
    #   Default value the argument takes.
    #
    # @option opts [#call] :constraint
    #   Proc which is passed the found argument and should return +true+ if the
    #   value is ok and false if not.
    #
    # @example
    #
    #   Argument.new(:arg, :optional => true, :type => Integer)
    #
    def initialize(name, opts={})
      opts  = (opts[0].is_a?(Hash) ? opts[0] : Hash[opts])
      @name = name.to_sym
  
      opts = DEFAULTS.merge(Hash[opts])

      @optional   = opts[:optional]
      @type       = Type.find_class(opts[:type].to_s)
      @match      = opts[:match]
      @within     = opts[:within]
      @default    = opts[:default]
      @constraint = opts[:constraint]
    end

    # Whether the argument is optional.
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

      r << "type=#@type"       if @type
      r << "match=#@match"     if @match
      r << "within=#@within"   if @within
      r << "default=#@default" if @default

      "#<#{r.join(' ')}>"
    end

    # Determines whether the object given (see param note), can be this argument.
    # Checks whether it is valid based on the options passed to Argument#initialize.
    #
    # @param obj [String,Object]
    #   This method will be called at least twice for each argument, the first
    #   time when testing for {Option#possible?} and then for {Option#valid?}.
    #   When called in {Option#possible?} +obj+ will be passed as a string,
    #   for {Option#valid?} though +obj+ will have been cast using {#coerce}
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
