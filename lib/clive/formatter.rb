module Clive

  # Formats the full help string displayed when the +help+ command is used
  # or the +--help+ option is invoked.
  class Formatter
  
    def initialize(header, footer, commands, options, padding=2)
      @header   = header
      @footer   = footer
      @commands = commands.sort
      @options  = options.sort
      @padding  = padding
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
      r << padding << "Commands:\n"
      
      @commands.each do |command|
        r << build_option_string(command)
      end
      
      r << "\n  Options:\n"
      @options.each do |option|
        r << build_option_string(option)
      end
      
      r << "\n" << @footer if @footer
      
      r
    end
    
    protected
    
    # Builds a single line for an Option of the form.
    #
    #  #{before_help_string} #{uniform_padding} #  #{after_help_string}
    #
    # @param [#before_help_string, #after_help_string]
    def build_option_string(opt)
      r = padding * 2 << opt.before_help_string
      unless opt.after_help_string.empty?
        r << padding_for(opt) << padding * 2 << "# " << opt.after_help_string
      end
      r << "\n"
      r
    end
    
    # @return [String] Default padding
    def padding
      ' ' * @padding
    end
    
    # @return [String] Padding for after the opt's #before_help_string.
    #  The size returned changes so that the descriptions line up
    def padding_for(opt)
      ' ' * (max - opt.before_help_string.size)
    end
    
    # @return [Integer] The length of the longest #before_help_string
    def max
      @max ||= (@options + @commands).map {|i| i.before_help_string.size }.max
    end
  
  end
end