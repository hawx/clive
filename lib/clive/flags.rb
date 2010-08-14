class Clive
  
  # A switch that takes an argument, with or without an equals
  #   eg. wget --tries=10
  #       wget -t 10
  #
  class Flag < Switch
  
    # Runs the block that was given with an argument
    #
    # @param [String] arg argument to pass to the block
    def run(arg)
      @block.call(arg)
    end
    
  end
end