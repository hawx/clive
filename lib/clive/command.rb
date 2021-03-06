class Clive

  # A command allows you to separate groups of commands under their own
  # namespace. But it can also take arguments like an Option. Instead of
  # executing the block passed to it executes the block passed to {#action}.
  #
  # @example
  #
  #   class CLI < Clive
  #
  #     command :new, arg: '<dir>' do
  #       # options
  #       bool :force
  #
  #       action do |dir|
  #         # code
  #       end
  #     end
  #
  #   end
  #
  class Command < Option

    # @return [Array<Option>] List of options created in the Command instance
    attr_reader :options

    DEFAULTS = {
      :group     => nil,
      :head      => false,
      :tail      => false,
      :runner    => Clive::Option::Runner,

      # these two are copied in from Base, so will be merged over
      :formatter => nil,
      :help      => nil,
      :name      => nil
    }

    # @param names [Array[Symbol]]
    #   Names that the Command can be ran with.
    #
    # @param desc [String]
    #   Description of the Command, this is shown in help and will be wrapped properly.
    #
    # @param config [Hash]
    # @option config [Boolean] :head
    #   If option should be at top of help list.
    # @option config [Boolean] :tail
    #   If option should be at bottom of help list.
    # @option config [String] :group
    #   Name of the group this option belongs to. This is actually set when
    #   {Command#group} is used.
    # @option config [Runner] :runner
    #   Class to use for running the block passed to #action. This doesn't have
    #   to be Option::Runner, but you probably never need to change this.
    # @option config [Formatter] :formatter
    #   Help formatter to use for this command, defaults to top-level formatter.
    # @option config [Boolean] :help
    #   Whether to add a '-h, --help' option to this command which displays help.
    # @option config [String] :args
    #   Arguments that the option takes. See {Argument}.
    # @option config [Type, Array[Type]] :as
    #   The class the argument(s) should be cast to. See {Type}.
    # @option config [#match, Array[#match]] :match
    #   Regular expression that the argument(s) must match.
    # @option config [#include?, Array[#include?]] :in
    #   Collection that argument(s) must be in.
    # @option config [Object] :default
    #   Default value that is used if argument is not given.
    #
    def initialize(names=[], description="", config={}, &block)
      @names       = names
      @description = description
      @options     = []
      @_block      = block

      @args = Arguments.create(get_subhash(config, Arguments::Parser::KEYS))
      @config = DEFAULTS.merge(get_subhash(config, DEFAULTS.keys))

      # Create basic header "Usage: filename commandname(s) [options]
      @header = proc { "Usage: #{@config[:name]} #{to_s} [options]" }
      @footer = ""
      @_group = nil

      add_help_option

      current_desc
    end

    # @return [Symbol] Single name to use when referring specifically to this command.
    #  Use the first name that was passed in.
    def name
      names.first
    end

    # @return [String]
    def to_s
      names.join(',')
    end

    # Runs the block that was given to {Command#initialize} within the context of the
    # command. The state hash is passed (and returned) so that {#set} works outside
    # of {Runner} allowing default values to be set.
    #
    # @param state [Hash] The newly created state for the command.
    # @return [Hash] The returned hash is used for the state of the command.
    def run_block(state)
      if @_block
        @state = state
        instance_exec(&@_block)
        @state
      else
        @state = state
      end
    end

    # @group DSL Methods

    # Set the header for {#help}.
    # @param [String]
    # @example
    #
    #   header 'Usage: my_app [options] [args]'
    #
    def header(val)
      @header = val
    end

    # Set the footer for {#help}.
    # @param [String]
    # @example
    #
    #   footer 'For more help visit http://mysite.com/help'
    #
    def footer(val)
      @footer = val
    end

    # Set configuration values for the command, as if you passed an options hash
    # to #initialize.
    #
    # @param [Hash] See #initialize
    # @example
    #
    #   config arg: '<dir>'
    #
    def config(opts=nil)
      if opts
        @config = @config.merge(get_subhash(opts, DEFAULTS.keys))
      else
        @config
      end
    end

    include Clive::StateActions

    # @overload option(short=nil, long=nil, description=current_desc, opts={}, &block)
    #   Creates a new Option in the Command. Either +short+ or +long+ must be set.
    #   @param short [Symbol] The short name for the option (:a would become +-a+)
    #   @param long [Symbol] The long name for the option (:add would become +--add+)
    #   @param description [String] Description of the option
    #   @param opts [Hash] Options to create the Option with, see {Option#initialize}
    #
    # @example
    #
    #   opt :type, arg: '<size>', in: %w(small medium large) do
    #     case size
    #       when "small"  then set(:size, 1)
    #       when "medium" then set(:size, 2)
    #       when "large"  then set(:size, 3)
    #     end
    #   end
    #
    def option(*args, &block)
      ns, d, o = [], current_desc, {}
      args.each do |i|
        case i
          when ::Symbol then ns << i
          when ::String then d = i
          when ::Hash   then o = i
        end
      end
      @options << Option.new(ns, d, ({:group => @_group}).merge(o), &block)
    end
    alias_method :opt, :option

    # @overload boolean(short=nil, long, description=current_desc, opts={}, &block)
    #   Creates a new Option in the Command which responds to calls with a 'no-' prefix.
    #   +long+ must be set.
    #   @param short [Symbol] The short name for the option (:a would become +-a+)
    #   @param long [Symbol] The long name for the option (:add would become +--add+)
    #   @param description [String] Description of the option
    #   @param opts [Hash] Options to create the Option with, see {Option#initialize}
    #
    # @example
    #
    #   bool :auto, 'Auto regenerate on changes'
    #
    #   # Usage
    #   #  --auto      sets :auto to true
    #   #  --no-auto   sets :auto to false
    #
    def boolean(*args, &block)
      ns, d, o = [], current_desc, {}
      args.each do |i|
        case i
          when ::Symbol then ns << i
          when ::String then d = i
          when ::Hash   then o = i
        end
      end
      @options << Option.new(ns, d, ({:group => @_group, :boolean => true}).merge(o), &block)
    end
    alias_method :bool, :boolean

    # If an argument is given it will set the description to that, otherwise it will
    # return the description for the command.
    #
    # @param arg [String]
    # @example
    #
    #   description 'Displays the current version'
    #   opt(:version) { puts $VERSION }
    #
    def description(arg=nil)
      if arg
        @_last_desc = arg
      else
        @description
      end
    end

    # Short version of {#description} which can only set.
    #
    # @param arg [String]
    # @example
    #
    #   desc 'Displays the current version'
    #   opt(:version) { puts $VERSION }
    #
    def desc(arg)
      @_last_desc = arg
    end

    # The action block is the block which will be executed with any arguments that
    # are found for it. It sets +@block+ so that {Option#run} does not have to be redefined.
    #
    # @example
    #
    #   command :create, arg: '<name>', 'Creates a new project' do
    #     bool :bare, "Don't add boilerplate code to created files"
    #
    #     action do |name|
    #       if get(:bare)
    #         # write some empty files
    #       else
    #         # create some files with stuff in
    #       end
    #     end
    #   end
    #
    def action(&block)
      @block = block
    end

    # Set the group name for all options defined after it.
    #
    # @param name [String]
    # @example
    #
    #   group 'Files'
    #   opt :move,   'Moves a file',   args: '<from> <to>'
    #   opt :delete, 'Deletes a file', arg:  '<file>'
    #   opt :create, 'Creates a file', arg:  '<name>'
    #
    #   group 'Network'
    #   opt :upload,   'Uploads everything'
    #   opt :download, 'Downloads everyhting'
    #
    def group(name)
      @_group = name
    end

    # Sugar for +group(nil)+
    def end_group
      group nil
    end

    # @endgroup

    # Finds the option represented by +arg+, this can either be the long name +--opt+
    # or the short name +-o+, if the option can't be found +nil+ is returned.
    #
    # @param arg [String]
    # @return [Option, nil]
    # @example
    #
    #   a = Command.new [:command] do
    #     bool :force
    #   end
    #
    #   a.find('--force')
    #   #=> #<Clive::Option --[no-]force>
    #
    def find(arg)
      if arg[0..1] == '--'
        find_option(arg[2..-1].gsub('-', '_').to_sym)
      elsif arg[0..0] == '-'
        find_option(arg[1..-1].to_sym)
      end
    end
    alias_method :[], :find

    # Attempts to find the option represented by the string +arg+, returns true if
    # it exists and false if not.
    #
    # @param arg [String]
    # @example
    #
    #   a = Command.new [:command] do
    #     bool :force
    #     bool :auto
    #   end
    #
    #   a.has?('--force')    #=> true
    #   a.has?('--auto')     #=> true
    #   a.has?('--no-auto')  #=> false
    #   a.has?('--not-real') #=> false
    #
    def has?(arg)
      !!find(arg)
    end

    # Finds the option with the name given by +arg+, this must be in Symbol form so
    # does not have a dash before it. As with {#find} if the option does not exist +nil+
    # will be returned.
    #
    # @param arg [Symbol]
    # @return [Option, nil]
    # @example
    #
    #   a = Command.new [:command] do
    #     bool :force
    #   end
    #
    #   a.find_option(:force)
    #   #=> #<Clive::Option --[no-]force>
    #
    def find_option(arg)
      @options.find {|opt| opt.names.include?(arg) }
    end

    # Attempts to find the option with the Symbol name given, returns true if the option
    # exists and false if not.
    #
    # @param arg [Symbol]
    def has_option?(arg)
      !!find_option(arg)
    end

    # @see Formatter
    # @return [String] Help string for this command.
    def help
      f = @config[:formatter]

      f.header   = @header.respond_to?(:call) ? @header.call : @header
      f.footer   = @footer.respond_to?(:call) ? @footer.call : @footer
      f.commands = @commands if @commands
      f.options  = @options

      f.to_s
    end

    private

    # Sets a value in the state.
    #
    # @param state [#store, #[]]
    # @param args [Array]
    # @param scope [nil]
    def set_state(state, args, scope=nil)
      # scope will always be nil, so ignore it for Option compatibility
      state[name].store :args, (@args.max <= 1 ? args[0] : args)
      state
    end

    # Adds the '--help' option to the Command instance if it should be added.
    def add_help_option
      if @config[:help] && !(has_option?(:help) || has_option?(:h))
        h = self # bind self so that it can be called in the block
        self.option(:h, :help, "Display this help message", :tail => true) do
          puts h.help
          exit 0
        end
      end
    end

    # @return [String]
    #   Returns the last description to be set with {#description}, it then clears the
    #   stored description so that it is not returned twice.
    def current_desc
      r = @_last_desc
      @_last_desc = ""
      r
    end

  end
end
