module Clive

  # Formats the full help string displayed when the +help+ command is used
  # or the +--help+ option is invoked.
  class Formatter
  
    attr_writer :header, :footer, :options, :commands
  
    # @param width [Integer] 
    #   Total width of screen to use
    # @param padding [Integer] 
    #   Amount of padding to use
    # @param ratio [Float] 
    #   Maximum proportion of screen the left side can use
    def initialize(width=Output.terminal_width, padding=2, min_ratio=0.3, max_ratio=0.5)
      @padding   = padding
      @width     = width
      @min_ratio = min_ratio
      @max_ratio = max_ratio
      
      @header, @footer = "", ""
      @commands, @options = [], []
    end
    
    # Builds the help string. Formatted like:
    #
    #  @header
    #   
    #    Commands:
    #      command            # Description
    #
    #    Options:
    #      -a, --abc <arg>    # Description
    #
    #  @footer
    #
    # @return [String]
    def to_s
      r = @header << "\n\n"
      
      unless @commands.empty?
        r << padding << "Commands:\n"
        @commands.each do |command|
          r << build_option_string(command)
        end
        r << "\n"
      end
      
      unless @options.empty?
        r << padding << "Options:\n"
        @options.each do |option|
          r << build_option_string(option)
        end
        r << "\n"
      end
      
      r << @footer if @footer
      
      r
    end
    
    def inspect
      "#<#{self.class.name} @width=#@width @padding=#@padding>"
    end
    
    protected
    
    # Builds a single line for an Option of the form.
    #
    #  #{before_help_string} #{uniform_padding} #  #{after_help_string}
    #
    # @param [#before_help_string, #after_help_string]
    def build_option_string(opt)
      r = padding * 2 << before(opt)
      
      unless after(opt).empty?
        r << padding_for(opt) << padding * 2
        r << "# " 
        r << Output.wrap_text(after(opt), left_width + 3, @width)
      end
      
      r << "\n"
      r
    end
    
    # @param opt [Option]
    # @return [String] First half of the help string, properly formatted
    def before(opt)
      b = opt.to_s.dup
      if opt.args != [] && !opt.boolean?
        b << " " << opt.args.to_s
      end
      
      b
    end
    
    # @param opt [Option]
    # @return [String] Second half of the help string, properly formatted
    def after(opt)
      a = opt.description.dup
      if opt.args.size == 1
        a << " " << opt.args.first.choice_str
      end
      a.strip
    end

    # @return [String] Default padding
    def padding
      ' ' * @padding
    end
    
    # @return [Integer] Width of the left half, ie. up to #after
    def left_width
      # (padding*2) longest before string (padding*2)
      w = max + (@padding * 4)
      if w > (@max_ratio * @width)
        (@max_ratio * @width).to_i
      elsif w < (@min_ratio * @width)
        (@min_ratio * @width).to_i
      else
        w.to_i
      end
    end
    
    # @return [String] Padding for after the opt's #before_help_string.
    #  The size returned changes so that the descriptions line up
    def padding_for(opt)
      ' ' * (max - before(opt).size)
    end
    
    # @return [Integer] The length of the longest #before_help_string
    def max
      @max ||= (@options + @commands).map {|i| before(i).size }.max
    end
  
  end
end