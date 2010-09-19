class Clive

  class Array < ::Array
    
    # If passed a Symbol or String will get the option or command with that name.
    # Otherwise does what you expect of an Array (see ::Array#[])
    #
    # @param [Symbol, String, Integer, Range] val name or index of item to return
    # @return the item that has been found
    def [](val)
      val = val.to_s if val.is_a? Symbol
      if val.is_a? String
        self.find_all {|i| i.names.include?(val)}[0]
      else
        super
      end
    end
    
    # Attempts to fill +self+ with values from +input+, giving priority to 
    # true, then false. If insufficient input to fill all false will use nil.
    #
    # @param [Array] input array of values to fill +self+ with
    # @return [Array] filled array
    #
    # @example
    #
    #   [true, false, false, true].optimise_fill(["a", "b", "c"])
    #   #=> ["a", "b", nil, "c"]
    #
    #
    def optimise_fill(input)
      match = self
      diff = input.size - match.reject{|i| i == false}.size
      
      result = []
      match.each_index do |i|
        curr_item = match[i]
        if curr_item == true
          result << input.shift
        else
          if diff > 0
            result << input.shift
            diff -= 1
          else
            result << nil
          end
        end
      end
      result
    end
    
  end
end