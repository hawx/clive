module Clive

  # An Argument represents an argument for an Option or Command, it can be optional
  # and can also be constricted by various other values.
  class Argument

    class AlwaysInclude
      def self.include?(arg)
        true
      end
    end

    class AlwaysMatch
      def self.match(arg)
        true
      end
    end

    DEFAULTS = {
      :optional => false,
      :type => Object,
      :match => AlwaysMatch,
      :within => AlwaysInclude,
      :default => nil,
      :constraint => proc {|a| true }
    }

    attr_reader :name, :default, :type

    # A new instance of Argument.
    #
    # @param name [Symbol, #to_sym]
    #   Name of the argument.
    #
    # @param optional [true, false]
    #   Whether this argument is optional. An optional argument does not have to be
    #   given and will instead pass +nil+ to the block.
    #
    # @param type [Type]
    #   Type that the matching argument should be cast to. See {Type} and the various
    #   subclasses for details.
    #
    # @param match [#match]
    #   Regular expression the argument must match.
    #
    # @param within [#include?]
    #   Collection that the matching argument should be in. This will be checked
    #   against the string argument and the cast object (see type above).
    #
    # @param default
    #   Default value the argument takes.
    #
    # @param constraint [#call]
    #   Proc which is passed the found argument and should return true if the value is
    #   ok and false if not.
    #
    # @example
    #
    #   Argument.new(:arg, :optional => true, :type => Integer)
    #
    def initialize(name, *opts)
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
      if optional?
        "[<#@name>]"
      else
        "<#@name>"
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

    # @param str [String] Found argument that could be this object's object.
    # @return [true, false] Whether +str+ could be this argument.
    def possible?(str)
      if !@type.valid?(str)
        return false
      end

      if !@match.match(str)
        return false
      end

      if !(@within.include?(str) || @within.include?(@type.typecast(str)))
        return false
      end
      
      begin
        return false unless @constraint.call(str)
      rescue
        return false unless @constraint.call(@type.typecast(str))
      end

      true
    end

    # Makes the found string argument the correct type.
    def coerce(str)
      if @type
        @type.typecast(str)
      else
        str
      end
    end

  end
end
