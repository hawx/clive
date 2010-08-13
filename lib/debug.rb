class Clive

  class Command
    def inspect
      "#<Clive::Command @name=\"#{@name}\">"
    end
  end
  
  class Switch
    def inspect
      "#<Clive::Switch @long=\"#{@long}\" @short=\"#{@short}\">"
    end
  end
  
  class Flag
    def inspect
      "#<Clive::Flag @long=\"#{@long}\" @short=\"#{@short}\">"
    end
  end

end