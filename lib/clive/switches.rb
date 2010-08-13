class Clive
  
  # Helper module to include to gain access to a #switch method. 
  # This assumes +@switches+ is available.
  module SwitchHelper
  
    # Add a new switch to +@switches+
    #
    # @overload switch(short, long, desc, &block)
    #   Creates a new switch
    #   @param [Symbol] short single character for short switch, eg. +:v+ => +-v+
    #   @param [Symbol] long longer switch to be used, eg. +:verbose+ => +--verbose+
    #   @param [String] desc the description for the switch
    #
    # @yield A block to run if the switch is triggered
    #
    def switch(*args, &block)
      short, long, desc = nil, nil, nil
      args.each do |i|
        if i.is_a? String
          desc = i
        elsif i.length == 1
          short = i.to_s
        else
          long = i.to_s
        end
      end
      @switches << Switch.new(short, long, desc, &block)
    end
  end
  
  class Switches < Array
    
    # If passed a Symbol or String will get the switch with that name,
    # checks long and short names. Otherwise does what you expect of an
    # Array (see Array#[])
    #
    # @param [Symbol, String, Integer] name or index of item to return
    # @return [Switch] the switch which has been found
    def [](val)
      val = val.to_s if val.is_a? Symbol
      if val.is_a? String
        if val.length == 1
          self.find_all {|i| i.short == val}[0]
        else
          self.find_all {|i| i.long == val}[0]
        end
      else
        super
      end
    end
  
  end
  
  # A string that takes no argument, beginning with a dash
  #   eg. the `-a` and `-l` in `ls -a -l` or `ls -al`
  #       the `--version` in `git --version`
  class Switch
    attr_accessor :short, :long, :desc, :block
    
    def initialize(short, long, desc, &block)
      @short = short
      @long = long
      @desc = desc
      @block = block
    end
    
    # Runs the block that was given
    def run
      @block.call
    end
    
  end
  
end