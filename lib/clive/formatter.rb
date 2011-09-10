module Clive

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
      r = ""
      r << padding * 2 << opt.before_help_string
      unless opt.after_help_string.empty?
        r << padding_for(opt) << padding * 2 << "# " << opt.after_help_string
      end
      r << "\n"
      r
    end
    
    def padding
      ' ' * @padding
    end
    
    def padding_for(opt)
      ' ' * (max - opt.before_help_string.size)
    end
    
    def command_strings
      Hash[@commands.map {|i| [i.before_help_string, i.after_help_string] }]
    end
    
    def option_strings
      Hash[@options.map {|i| [i.before_help_string, i.after_help_string] }]
    end
    
    def max
      (@options + @commands).map {|i| i.before_help_string.size }.max
    end
  
  end
end