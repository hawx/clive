class Clive
  class Base < Command

    attr_reader :commands

    OPT_KEYS = Command::OPT_KEYS + [:help_command, :debug]

    DEFAULTS = {
      :formatter    => Formatter::Colour.new,
      :help_command => true,
      :help         => true,
    }

    # These options should be copied into each {Command} that is created.
    GLOBAL_OPTIONS = [:formatter, :help]

    # Never create an instance of this yourself. Extend Clive, then call #run.
    def initialize(&block)
      super

      @commands = []
      @header   = "Usage: #{File.basename($0)} [command] [options]"
      @footer   = ""
      @_group   = nil
      @opts     = DEFAULTS

      # Need to keep a state before #run is called so #set works.
      @pre_state = {}
      instance_exec &block if block
    end

    # Need to define #set here for the class that extends Clive.
    # @see Option::Runner#set
    def set(key, value)
      @pre_state.store key, value
    end

    def run(argv, opts={})
      @opts = DEFAULTS.merge( get_and_rename_hash(opts, OPT_KEYS) || {} )

      add_help_option
      add_help_command

      Clive::Parser.new(self, opts).parse(argv, @pre_state)
    end

    def global_opts
      @opts.find_all {|k,v| GLOBAL_OPTIONS.include?(k) }
    end

    # Creates a new Command.
    #
    # @overload option(names=[], description=current_desc, opts={}, &block)
    #   Creates a new Command.
    #   @param names [Array<Symbol>] Names that the command can be called with.
    #   @param description [String] Description of the command.
    #   @param opts [Hash] Options to be passed to the new Command, see {Command#initialize}.
    #
    def command(*args, &block)
      ns, d, o = [], current_desc, {}
      args.each do |i|
        case i
          when ::Symbol then ns << i
          when ::String then d = i
          when ::Hash   then o = i
        end
      end
      o = DEFAULTS.merge(Hash[global_opts]).merge(o)
      @commands << Command.new(ns, d, o.merge({:group => @_group}), &block)
    end

    # @see Command#find
    def find(arg)
      if arg[0..0] == '-'
        super
      else
        find_command(arg.to_sym)
      end
    end

    # @param arg [Symbol]
    def find_command(arg)
      @commands.find {|i| i.names.include?(arg) }
    end

    # @param arg [Symbol]
    def has_command?(arg)
      !!find_command(arg)
    end

    private

    # Adds the help command, which accepts the name of a command to display help
    # for, to this if it is wanted.
    def add_help_command
      if @opts[:help] && @opts[:help_command] && !has_command?(:help)
        self.command(:help, 'Display help', :arg => '[<command>]', :tail => true)
      end
    end

  end
end
