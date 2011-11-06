module Clive
  class Formatter
  
    class Plain < Formatter
    
      DEFAULTS = {
        # [Integer] Amount of left padding to use
        :padding   => 2,
        # [Integer] Total width of screen to use
        :width     => Output.terminal_width,
        # [Float] Minimum proportion of screen the left side can use
        :min_ratio => 0.2,
        # [Float] Maximum proportion of screen the left side can use
        :max_ratio => 0.4
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
  
      # @return [String] Default padding
      def padding
        ' ' * @opts[:padding]
      end
      
      # @return [Integer] Width of the left half, ie. up to {#after}
      def left_width
        w = max + (@opts[:padding] * 4)
        if w > @opts[:max_ratio] * @opts[:width]
          (@opts[:max_ratio] * @opts[:width]).to_i
        elsif w < @opts[:min_ratio] * @opts[:width]
          (@opts[:min_ratio] * @opts[:width]).to_i
        else
          w.to_i
        end
      end
      
      # @return [Integer] The greatest width the left part of the screen
      #  can be. This allows you to use _a_ max width in calculations 
      #  without creating a loop.
      def max_left_width
        (@opts[:max_ratio] * @opts[:width]).to_i
      end
      
      # @param opt [Option]
      # @return [String] Padding for after the opt's {#before}.
      #  The size returned changes so that the descriptions line up.
      def padding_for(opt)
        width = left_width - before_for(opt).clear_colours.split("\n").last.size
        if width >= 0
          ' ' * width
        else
          ' ' * left_width
        end
      end
      
      # @return [Integer] The length of the longest {#before}
      def max
        (@options + @commands).map {|i| before_for(i).size }.max
      end
      
      
      # Builds a single line for an Option of the form.
      #
      #  before padding   # after
      #
      # @param [Option]
      def build_option_string(opt)
        before_for(opt) << padding_for(opt) << (padding * 2) << after_for(opt).rstrip << "\n"
      end
      
      def before_for(opt)
        b = (padding * 2) << names_for(opt).dup << " " << args_for(opt)
        b << "\n" if b.size > max_left_width
        b
      end
      
      def after_for(opt)
        r = ""
        after = description_for(opt).dup << " " << choices_for(opt)
        unless after.empty?
          r << "# " << Output.wrap_text(after, left_width + 4, @opts[:width])
        end
        r
      end
      
      def names_for(opt)
        opt.to_s
      end
      
      def description_for(opt)
        opt.description
      end
      
      def args_for(opt)
        if opt.args != [] && !opt.boolean?
          opt.args.to_s
        else
          ""
        end
      end
      
      def choices_for(opt)
        if opt.args.size == 1 && !opt.args.first.choice_str.empty?
          opt.args.first.choice_str
        else
          ""
        end
      end
      
    end
  end
end