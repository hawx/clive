module Clive

  # Formats the full help string displayed when the +help+ command is used
  # or the +--help+ option is invoked. This can be replaced by a class of
  # your own design if necessary. The only requirements are that it must 
  # respond to #to_s which should return the help string, and respond to
  # #header=, #footer=, #options= and #commands=.
  #
  # Then it is just a case of passing an instance of the new formatter to
  # {Clive.run}. You can also use a different formatter for commands by 
  # passing it when creating them.
  #
  # @example
  #
  #   class MainFormatter
  #     # ...
  #   end
  #
  #   class CommandFormatter
  #     # ...
  #   end
  #
  #   class CLI
  #     # ...
  #
  #     command :new, formatter: CommandFormatter.new do
  #       # ...
  #     end
  #   end
  #
  #   CLI.run formatter: MainFormatter.new
  #
  class Formatter
  
    attr_writer :header, :footer, :options, :commands
  
    # @param width [Integer] 
    #   Total width of screen to use
    # @param padding [Integer] 
    #   Amount of padding to use
    # @param min_ratio [Float] 
    #   Minimum proportion of screen the left side can use
    # @param max_ratio [Float]
    #   Maximum proportion of screen the left side can use
    #
    def initialize(width=Output.terminal_width, padding=2, min_ratio=0.3, max_ratio=0.5)
      @padding   = padding
      @width     = width
      @min_ratio = min_ratio
      @max_ratio = [min_ratio, max_ratio].max # max_ratio can't be smaller than min
      
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
      @commands.sort!
      @options.sort!
    
      # Make sure to #dup or it just appends each time, getting ever longer
      r = @header.dup << "\n\n"
      
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
    # @param [Option]
    def build_option_string(opt)
      r = before(opt)
      
      unless after(opt).empty?
        r << padding_for(opt) << (padding * 2)
        r << "# " 
        r << Output.wrap_text(after(opt), left_width + 4, @width)
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
        b = (padding * 2) << Output.wrap_text(b, (@padding * 2) + 3, max_left_width)
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
    
    # @return [Integer] The greatest width the left part of the screen
    #  can be. This allows you to use _a_ max width in calculations 
    #  without creating a loop.
    def max_left_width
      @max_ratio * @width
    end
    
    # @param opt [Option]
    # @return [String] Padding for after the opt's #before_help_string.
    #  The size returned changes so that the descriptions line up.
    def padding_for(opt)
      width = left_width - @padding - before(opt).split("\n").last.size
      ' ' * width
    end
    
    # @return [Integer] The length of the longest #before_help_string
    def max
      (@options + @commands).map {|i| before(i).size }.max
    end
  
  end
end