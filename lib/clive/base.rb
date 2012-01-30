class Clive
  class Base < Command

    attr_reader :commands

    DEFAULTS = {
      :name         => File.basename($0),
      :formatter    => Formatter::Colour.new,
      :help_command => true,
      :help         => true
    }

    # These options should be copied into each {Command} that is created.
    GLOBAL_OPTIONS = [:name, :formatter, :help]

    # You don't need to create an instance of this, create a class extending
    # Clive or call Clive.new instead.
    #
    # @param config [Hash] Options to set for this Base, see #run for details
    #  of the keys that can be passed.
    def initialize(config={}, &block)
      super([], config, &block)

      @commands = []
      @header   = proc { "Usage: #{@config[:name]} [command] [options]" }
      @footer   = ""
      @_group   = nil
      @config   = DEFAULTS.merge(get_subhash(config, DEFAULTS.keys))

      # Need to keep a state before #run is called so #set works.
      @state = {}
      instance_exec &block if block
    end

    # Runs the Clive with the args passed which defaults to +ARGV+.
    #
    # @param args [Array<String>]
    #   Command line arguments to run with
    #
    # @param config [Hash]
    # @option config [Boolean] :help
    #   Whether to create a help option.
    # @option config [Boolean] :help_command
    #   Whether to create a help command.
    # @option config [Formatter] :formatter
    #   Help formatter to use.
    # @option config [String] :name
    #   Name to use in headers, this is usually better than setting a header as
    #   commands will use this to generate their own headers for use in help.
    #
    def run(args=ARGV, config={})
      @config = @config.merge(get_subhash(config, DEFAULTS.keys))

      add_help_option
      add_help_command

      Clive::Parser.new(self, config).parse(args, @state)
    end


    # @group DSL Methods

    # @overload command(*names, description=current_desc, opts={}, &block)
    #   Creates a new Command.  @param names [Array<Symbol>] Names that the
    #   command can be called with.  @param description [String] Description of
    #   the command.  @param opts [Hash] Options to be passed to the new
    #   Command, see {Command#initialize}.
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
      @config.find_all {|k,v| GLOBAL_OPTIONS.include?(k) }
    end

    # Adds the help command, which accepts the name of a command to display help
    # for, to this if it is wanted.
    def add_help_command
      if @config[:help] && @config[:help_command] && !has_command?(:help)
        self.command(:help, 'Display help', :arg => '[<command>]', :tail => true)
      end
    end

  end
end
