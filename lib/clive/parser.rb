class Clive

  class Parser

    class MissingArgumentError < Error
      reason 'missing argument for #0, found #1, needed #2'
    end

    class MissingOptionError < Error
      reason 'option could not be found: #0'
    end

    DEFAULTS = {
      :state => ::Clive::StructHash
    }

    # @param base [Command]
    #
    # @param config [Hash]
    # @option config [.new, #[], #[]=, #alias] :state
    #   What class the state should be
    def initialize(base, config)
      @base = base
      @config = DEFAULTS.merge(config)
    end

    # The parser should work how you expect. It allows you to put global options before and after
    # a command section (if it exists, which it doesn't), so you have something like.
    #
    #    my_app.rb [global options] ([command] [options] [args]) [g. options] [g. args] [g. options] etc.
    #            |  global section  |    command section       |      global section
    #
    # Only one command can be run, if you attempt to use two the other will be caught as an argument.
    #
    # @param argv [Array]
    #   The input to parse from the command line, usually ARGV.
    #
    # @param pre_state [Hash]
    #   A pre-populated state to be used.
    #
    def parse(argv, pre_state)
      @argv = argv
      @i    = 0

      @state = @config[:state].new(pre_state)
      @state.store :args, []

      # Pull out 'help' command immediately if found
      if @argv[0] == 'help'
        if @argv[1]
          if @base.has?(@argv[1])
            command = @base.find(@argv[1])
            command.run_block({})
            puts command.help
          else
            puts "Error: command #{@argv[1]} could not be found. Try `help` to see the available commands."
          end
        else
          puts @base.help
        end
      end

      until ended?
        # does +curr+ exist? (and also check that if it is a command a command hasn't been run yet
        if @base.has?(curr) && ((@base.find(curr).kind_of?(Command) && !command_ran?) || @base.find(curr).kind_of?(Option))

          found = @base.find(curr)

          # is it a command?
          if found.kind_of?(Command)
            @command_ran = true
            @state.store found.names, found.run_block(@config[:state].new)

            inc
            args = []

            until ended?
              if found.has?(curr)
                run_option found.find(curr), found
              else
                break unless found.args.possible?(args + [curr])
                args << curr
              end
              inc
            end
            dec

            found.run @state, validate_arguments(found, args), found

          # otherwise it is an option
          else
            run_option found
          end

        # it's a no- option
        elsif curr[0..4] == '--no-' && @base.find("--#{curr[5..-1]}").config[:boolean] == true
          @base.find("--#{curr[5..-1]}").run @state, [false]

        # it's one (or more) short options
        elsif curr[0..0] == '-' && curr.size > 2 && @base.has?("-#{curr[1..1]}")
          currs = curr[1..-1].split('').map {|i| "-#{i}" }

          currs.each do |c|
            opt = @base.find(c)
            raise MissingOptionError.new(c) unless opt

            if c == currs.last
              run_option opt
            else
              # can't take any arguments as an option is next to it
              if opt.args.min > 0
                raise MissingArgumentError.new(opt, [], opt.args)
              else
                opt.run @state, [true]
              end
            end
          end

        # otherwise it is an argument
        else
          @state.args << curr
        end

        inc
      end

      @state
    end


    private

    def run_option(opt, within=nil)
      args = opt.args.max > 0 ? do_arguments_for(opt) : [true]
      opt.run @state, args, within
    end

    # Increment the index
    def inc
      @i += 1
    end

    # Decrement the index
    def dec
      @i -= 1
    end

    # @return [String] The current token
    def curr
      @argv[@i]
    end

    # Whether the index is at the end of the argv
    def ended?
      @i >= @argv.size
    end

    def command_ran?
      @command_ran || false
    end

    # Returns the finished argument list for +opt+ which can then be pushed to the state.
    def do_arguments_for(opt)
      arg_list = collect_arguments(opt)
      arg_list = validate_arguments(opt, arg_list)

      arg_list
    end

    # Collects the arguments for +opt+.
    def collect_arguments(opt)
      inc
      arg_list = []
      while !ended? && arg_list.size < opt.args.max
        break unless opt.args.possible?(arg_list + [curr])
        arg_list << curr
        inc
      end
      dec
      arg_list
    end

    # Makes sure the found list of arguments is valid, if not raises
    # MissingArgumentError. Returns the valid argument list with the arguments
    # as the correct type, in the correct positions and with default values
    # inserted if necessary.
    def validate_arguments(opt, arg_list)
      # If we don't have enough args
      unless opt.args.valid?(arg_list)
        raise MissingArgumentError.new(opt, arg_list, opt.args.to_s)
      end

      opt.args.create_valid(arg_list)
    end

  end
end
