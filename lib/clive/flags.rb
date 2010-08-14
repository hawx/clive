class Clive
  
  # A switch that takes an argument
  #   eg. git merge -s resolve
  #       git merge --strategy=resolve
  class Flag < Switch
  
    # Runs the block that was given with an argument
    #
    # @param [String] arg argument to pass to the block
    def run(arg)
      @block.call(arg)
    end
    
  end
end