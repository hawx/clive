module Clive

  class Argument
  
    attr_reader :name
  
    # @param name [Symbol, #to_sym]
    #   Name of the argument.
    # @param optional [true, false]
    #   Whether this argument is optional.
    # @param type [#_coerce, #_matches?]
    #   Type that the matching argument should be cast to.
    # @param match [Regexp, #match]
    #   Regular expression the argument must match.
    # @param within [Array, #include?]
    #   Collection that the matching argument should be in.
    def initialize(name, optional, type=nil, match=nil, within=nil)
      @name     = name.to_sym
      @optional = optional
      @type     = type
      @match    = match
      @within   = within
    end
    
    def optional?
      @optional
    end
    
    def to_s
      if optional?
        "[<#@name>]"
      else
        "<#@name>"
      end
    end
    
    # @param str [String] Found argument that could be this object's object.
    # @return [true, false] Whether +str+ could be this argument.
    def possible?(str)
      if @type && !@type._matches?(str)
        return false
      end
      
      if @match && !@match.match(str)
        return false
      end
      
      if @within && !(@within.include?(str) && @within.include?(@type._coerce(str)))
        return false
      end
      
      true
    end
    
    def coerce(str)
      if @type
        @type._coerce(str)
      else
        str
      end
    end
  
  end
end




## ARGUMENT TYPES ##

class Object
  def _matches?(arg)
    true
  end
  
  def _coerce(arg)
    arg
  end
end

class Integer
  def _matches?(arg)
    arg =~ /\d+/
  end
  
  def _coerce(arg)
    arg.to_i
  end
end

require 'time'
class Time
  # any parseable time
  def self._matches?(arg)
    Time.parse(arg)
    true
  rescue
    false
  end
  
  def self._coerce(arg)
    Time.parse(arg)
  end
end