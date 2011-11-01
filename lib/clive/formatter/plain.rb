module Clive
  class Formatter
  
    class Plain < Formatter
    
      DEFAULTS = {
        # [Integer] Amount of left padding to use
        :padding   => 2,
        # [Integer] Total width of screen to use
        :width     => Output.terminal_width,
        # [Float] Minimum proportion of screen the left side can use
        :min_ratio => 0.3,
        # [Float] Maximum proportion of screen the left side can use
        :max_ratio => 0.5
      }
      
      # @param opts [Hash]
      # @option opts [Integer] :width
      #   Total width of screen to use
      # @option opts [Integer] :padding
      #   Amount of padding to use
      # @option opts [Float] :min_ratio
      #   Minimum proportion of screen the left side can use
      # @option opts [Float] :max_ratio
      #   Maximum proportion of screen the left side can use
      def initialize(opts={})
        @opts = DEFAULTS.merge(opts)
        
        if @opts[:min_ratio] > @opts[:max_ratio]
          @opts[:max_ratio] = @opts[:min_ratio]
        end
        
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
        groups = (@options + @commands).group_by {|i| i.opts[:group] }
              
        # So no groups were created, let's create some nice defaults
        if groups.size == 1 && groups.keys.first == nil
          # Use an array so that the order is always correct
          groups = [['Commands', @commands.sort], ['Options', @options.sort]]
        end
  
        r = @header.dup << "\n\n"
        
        groups.each do |name, group|
          unless group.empty?
            r << (name ? "#{padding}#{name}:\n" : '')
            group.sort.sort_by {|i| i.instance_of?(Command) ? 0 : 1 }.each do |opt|
              r << build_option_string(opt)
            end
            r << "\n"
          end
        end
      
        r << @footer
        
        r
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
          r << "# " unless opt.description.empty?
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
        a = opt.description.dup
        if opt.args.size == 1
          a << " " << opt.args.first.choice_str
        end
        a.strip
      end
  
      # @return [String] Default padding
      def padding
        ' ' * @opts[:padding]
      end
      
      # @return [Integer] Width of the left half, ie. up to {#after}
      def left_width
        # (padding*2) longest before string (padding*2)
        w = max + (@opts[:padding] * 4)
        if w > (@opts[:max_ratio] * @opts[:width])
          (@opts[:max_ratio] * @opts[:width]).to_i
        elsif w < (@opts[:min_ratio] * @opts[:width])
          (@opts[:min_ratio] * @opts[:width]).to_i
        else
          w.to_i
        end
      end
      
      # @return [Integer] The greatest width the left part of the screen
      #  can be. This allows you to use _a_ max width in calculations 
      #  without creating a loop.
      def max_left_width
        @opts[:max_ratio] * @opts[:width]
      end
      
      # @param opt [Option]
      # @return [String] Padding for after the opt's {#before}.
      #  The size returned changes so that the descriptions line up.
      def padding_for(opt)
        width = left_width - @opts[:padding] - before(opt).clear_colours.split("\n").last.size
        ' ' * width
      end
      
      # @return [Integer] The length of the longest {#before}
      def max
        (@options + @commands).map {|i| before(i).size }.max
      end
      
    end
  end
end