class Clive

  class Array < ::Array
    
    # If passed a Symbol or String will get the item with that name,
    # checks #long and #short if available or #name. Otherwise does 
    # what you expect of an Array (see Array#[])
    #
    # @param [Symbol, String, Integer, Range] val name or index of item to return
    # @return the item that has been found
    def [](val)
      val = val.to_s if val.is_a? Symbol
      if val.is_a? String
        if self[0].respond_to?(:name)
          self.find_all {|i| i.name == val}[0]
        elsif self[0].respond_to?(:long) 
          if val.length == 1
            self.find_all {|i| i.short == val}[0]
          else
            self.find_all {|i| i.long == val}[0]
          end
        end
      else
        super
      end
    end
    
  end
end