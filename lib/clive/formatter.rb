module Clive

  class Formatter
  
    def initialize(header, footer, commands, options)
      @header   = header
      @footer   = footer
      @commands = commands
      @options  = options
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
      command_strings = Hash[@commands.map {|i| [i, [i.before_help_string, i.after_help_string]] }]
      option_strings = Hash[@options.map {|i| [i, [i.before_help_string, i.after_help_string]] }]
      
      max = [
        command_strings.values.map {|i| i[0].size }.max,
        option_strings.values.map {|i| i[0].size }.max
      ].max
      
      padding = '  '
      
      r = @header << "\n\n"
      r << padding << "Commands:\n"
      command_strings.sort_by {|i| i[0] }.each do |_, (b, a)|
        r << padding * 2 << b 
        r << (" " * (max - b.size)) << padding * 2 << "# " << a unless a.empty?
        r << "\n"
      end
      
      r << "\n  Options:\n"
      option_strings.sort_by {|i| i[0] }.each do |_, (b, a)|
        r << padding * 2 << b 
        r << (" " * (max - b.size)) << padding * 2 << "# " << a unless a.empty?
        r << "\n"
      end
      
      r << "\n" << @footer if @footer
      
      r
    end
  
  end
end