class Clive
  class Base < Command

    attr_reader :commands

    DEFAULTS = {
      :formatter    => Formatter::Colour.new,
      :help_command => true,
      :help         => true,
    }

    # These options should be copied into each {Command} that is created.
    GLOBAL_OPTIONS = [:formatter, :help]

    # You don't need to create an instance of this, create a class extending
    # Clive or call Clive.new instead.
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

    # Runs the Clive with the args passed which defaults to +ARGV+.
    #
    # @param args [Array<String>] Command line arguments to run with
    # @param opts [Hash] Options to run with
    # @option opts [Boolean] :help Whether to create a help option
    # @option opts [Boolean] :help_command Whether to create a help command
    # @option opts [Formatter] :formatter Help formatter to use
    def run(args=ARGV, opts={})
      @opts = DEFAULTS.merge( get_subhash(opts, DEFAULTS.keys) || {} )

      add_help_option
      add_help_command

      Clive::Parser.new(self, opts).parse(args, @pre_state)
    end


    # @group DSL Methods

    # @overload command(*names, description=current_desc, opts={}, &block)
    #   Creates a new Command.
    #   @param names [Array<Symbol>] Names that the command can be called with.
    #   @param description [String] Description of the command.
    #   @param opts [Hash] Options to be passed to the new Command, see {Command#initialize}.
    #
    # @example
    #
    #   class CLI
    #     desc 'Creates a new thing'
    #     command :create, arg: '<thing>' do
    #       # ...
    #     end
    #   end
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

    # Sets a value in the state. Useful for setting default values.
    # @see Option::Runner#set
    # @example
    #
    #   class CLI
    #     set :size, :medium
    #
    #     opt :size, arg: '<size>', in: %w(small medium large), as: Symbol do
    #       set :size, size
    #     end
    #   end
    #
    def set(key, value)
      @pre_state.store key, value
    end

    # @endgroup

    # Finds the option or command represented by +arg+, this can the name of a command
    # or an option which should include the correct number of dashes. If the option or
    # command cannot be found +nil+ is returned.
    #
    # @param arg [String]
    # @see Command#find
    # @example
    #
    #   c = Clive.new {
    #     command :new
    #     opt :v, :version
    #   }
    #
    #   c.find('-v')
    #   #=> #<Clive::Option -v, --version>
    #   c.find('new')
    #   #=> #<Clive::Command new>
    #   c.find('test')
    #   #=> nil
    #
    def find(arg)
      if arg[0..0] == '-'
        super
      else
        find_command(arg.to_sym)
      end
    end

    # Finds the command with the name given, if the command cannot be found
    # returns +nil+.
    #
    # @param arg [Symbol, nil]
    # @example
    #
    #   c = Clive.new {
    #     command :new
    #   }
    #
    #   c.find_command(:new)
    #   #=> #<Clive::Command new>
    #
    def find_command(arg)
      @commands.find {|i| i.names.include?(arg) }
    end

    # Attempts to find the command with the name given, returns true if the
    # command exits.
    #
    # @param arg [Symbol]
    # @example
    #
    #   c = Clive.new {
    #     command :new
    #   }
    #
    #   c.has_command? :new     #=> true
    #   c.has_command? :create  #=> false
    #
    def has_command?(arg)
      !!find_command(arg)
    end

    private

    # Options which should be copied into each Command created.
    def global_opts
      @opts.find_all {|k,v| GLOBAL_OPTIONS.include?(k) }
    end

    # Adds the help command, which accepts the name of a command to display help
    # for, to this if it is wanted.
    def add_help_command
      if @opts[:help] && @opts[:help_command] && !has_command?(:help)
        self.command(:help, 'Display help', :arg => '[<command>]', :tail => true)
      end
    end

  end
end
