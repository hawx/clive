module Clive
  class Formatter
  
    class Colour < Plain
      
      def after_for(opt)
        r = ""
        after = description_for(opt).dup << " " << choices_for(opt)
        unless after == " "
          r << "# ".grey << Output.wrap_text(after, left_width + padding(2).size, @opts[:width])
        end
        r
      end
      
      def description_for(opt)
        s = super
        if s.empty?
          s
        else
          s.grey
        end
      end
      
      def choices_for(opt)
        s = super
        if s.empty?
          s
        else
          s.blue.bold
        end
      end
    
    end
  end
end