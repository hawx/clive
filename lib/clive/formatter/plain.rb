class Clive
  class Formatter

    class Plain < Formatter

      DEFAULTS = {
        :padding   => 2,
        :width     => Output.terminal_width,
        :min_ratio => 0.2,
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
      #  Usage: the header
      #
      #    Commands:
      #      command            # Description
      #
      #    Options:
      #      -a, --abc <arg>    # Description
      #
      #  A footer
      #
      # @return [String]
      def to_s
        groups = (@options + @commands).group_by {|i| i.config[:group] }

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
        r.split("\n").map {|i| i.rstrip }.join("\n")
      end

      protected

      # @return [String] Default padding
      def padding(n=1)
        ' ' * (@opts[:padding] * n)
      end

      # @return [Integer] Width of the left half, ie. up to {#after}
      def left_width
        w = max + padding(2).size
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

      # @return [Integer] The length of the longest {#before}, ignoring any that break
      #  the line.
      def max
        (@options + @commands).map {|i|
          before_for(i).size
        }.reject {|i|
          i > max_left_width
        }.max
      end

      # Builds a single line for an Option of the form.
      #
      #  before padding   # after
      #
      # @param [Option]
      def build_option_string(opt)
        before_for(opt) << padding_for(opt) << padding << after_for(opt).rstrip << "\n"
      end

      # @param opt [Option]
      # @return [String] Builds the first half of the help string for an Option.
      def before_for(opt)
        b = padding(2) << names_for(opt).dup << " " << args_for(opt)
        b << "\n" if b.size > max_left_width
        b
      end

      # @return [String] Padding for between an Option's #before and #after.
      def padding_for(opt)
        width = left_width - before_for(opt).clear_colours.split("\n").last.size
        if width >= 0
          ' ' * width
        else
          ' ' * left_width
        end
      end

      # @param opt [Option]
      # @return [String] Builds the second half of the help string for an Option.
      def after_for(opt)
        r = ""
        after = description_for(opt).dup << " " << choices_for(opt)
        unless after == " "
          r << "# "
          r << Output.wrap_text(after, left_width + padding(2).size, @opts[:width])
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
        if opt.args != [] && !opt.config[:boolean] == true
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
