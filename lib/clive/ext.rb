class Clive

  class Array < ::Array
    
    # If passed a Symbol or String will get the item with that name.
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
    
  end
end