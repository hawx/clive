module Clive
  class Formatter
  
    class Colour < Plain
    
      # Builds a single line for an Option of the form.
      #
      #  #{before_help_string} #{uniform_padding} #  #{after_help_string}
      #
      # @param [Option]
      def build_option_string(opt)
        r = before(opt)
        
        unless after(opt).empty?
          r << padding_for(opt) << (padding * 2)
          r << "# ".grey unless opt.description.empty?
          r << Output.wrap_text(after(opt), left_width + 4, @opts[:width])
        end
        
        r << "\n"
        r
      end
    
      # @param opt [Option]
      # @return [String] First half of the help string, properly formatted
      def before(opt)
        b = (padding * 2) << opt.to_s.dup
        if opt.args != [] && !opt.boolean?
          b << " " << opt.args.to_s
        end
        
        if b.size > max_left_width
          # re add padding because .wrap_text removes it
          b = (padding * 2) << Output.wrap_text(b, (@opts[:padding] * 2) + 3, max_left_width)
        end
        
        b
      end
      
      # @param opt [Option]
      # @return [String] Second half of the help string, properly formatted
      def after(opt)
        a = opt.description.dup.grey
        if opt.args.size == 1
          a << " " << opt.args.first.choice_str.blue.bold
        end
        a.strip
      end
    
    end
  end
end