class Clive
  
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