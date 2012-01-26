class Clive

  # @abstract Subclass and override {#to_s} (and probably {#initialize}) to
  #  implement a custom Formatter. {#initialize} *should* take an options
  #  hash.
  #
  # Takes care of formatting the help string. Look at {Formatter::Plain}
  # for a good (if not a bit complex) reference of how to do it.
  #
  # Then it is just a case of passing an instance of the new formatter to
  # {Clive.run}. You can use a different formatter for commands by
  # passing it when creating them.
  #
  # @example
  #
  #   class MainFormatter < Clive::Formatter
  #     # ...
  #   end
  #
  #   class CommandFormatter < Clive::Formatter
  #     # ...
  #   end
  #
  #   # Uses MainFormatter
  #   class CLI
  #     # ...
  #
  #     # Uses CommandFormatter
  #     command :new, formatter: CommandFormatter.new do
  #       # ...
  #     end
  #
  #     # Uses MainFormatter
  #     command :normal do
  #       # ...
  #     end
  #   end
  #
  #   CLI.run formatter: MainFormatter.new
  #
  class Formatter

    attr_writer :header, :footer, :options, :commands

    def initialize(opts={})
      @opts = opts

      @header, @footer = '', ''
      @commands, @options = [], []
    end

    def to_s
      ([@header] + @commands + @options + [@footer]).join("\n")
    end

    def inspect
      "#<#{self.class.name} @opts=#@opts>"
    end
  end

end
