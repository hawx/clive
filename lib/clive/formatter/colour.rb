module Clive
  class Formatter
  
    class Colour < Plain
      
      def after_for(opt)
        r = ""
        after = description_for(opt).dup << " " << choices_for(opt)
        unless after.empty?
          r << "# ".grey << Output.wrap_text(after, left_width + 6, @opts[:width])
        end
        r
      end
      
      def description_for(opt)
        super.grey
      end
      
      def choices_for(opt)
        super.blue.bold
      end
    
    end
  end
end