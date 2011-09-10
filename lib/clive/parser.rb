module Clive

  class Parser

    class MissingArgumentError < Error
      reason 'missing argument for #0, found #1, needed #2'
    end
    
    class MissingOptionError < Error
      reason 'option could not be found: #0'
    end

    # :state [#[], #[]=] Used to store values from options that do not trigger blocks.
    # :debug [Boolean] Whether to print debug messages, useful if parsing oddly.
    DEFAULTS = {
      :state => Hash,
      :debug => false
    }

    def initialize(base)
      @base = base
    end

    attr_accessor :i, :state, :arguments, :argv

    def inc
      @i += 1
    end

    def dec
      @i -= 1
    end

    def curr
      argv[i]
    end

    def ended?
      i >= argv.size
    end

    def debug(str)
      puts @debug_padding.to_s + str.l_cyan if @opts[:debug]
    end

    # The parser should work how you expect. It allows you to put global options before and after
    # a command section (if it exists, which it doesn't), so you have something like.
    #
    #    my_app.rb [global options] ([command] [options] [args]) [g. options] [g. args] [g. options] etc.
    #            |  global section  |    command section       |      global section
    #
    # Only one command can be run, if you attempt to use two the other will be caught as an argument.
    #
    def parse(argv, opts={})
      @argv = argv
      @opts = DEFAULTS.merge(opts)
      @i = 0

      @arguments   = []
      @state       = @opts[:state].new
      command_ran  = false # only one command can be ran per parse!
      
      # Pull out 'help' command immediately if found
      if @argv[0] == 'help'
        if @argv[1]
          puts @base.find[@argv[1]].help
        else
          puts @base.help
        end
      end

      until ended?
        # does +curr+ exist? (and also check that if it is a command a command hasn't been run yet
        if @base.has?(curr) && ((@base.find(curr).kind_of?(Command) && !command_ran) || (@base.find(curr).kind_of?(Option)))
        
          found = @base.find(curr)

          # is it a command?
          if found.kind_of?(Command)
            command_ran = true
            found.run_block

            debug "Found command: #{found}"
            @debug_padding = "  "

            inc
            state[found.name] = @opts[:state].new
            command_args = []

            until ended?
              if found.has?(curr)
                opt = found.find(curr)
                debug "Found option: #{opt}"
                
                args = opt.max_args > 0 ? do_arguments_for(opt) : [true]

                if opt.block?
                  opt.run(state[found.name], args)
                else
                  state[found.name][opt.name] = (opt.max_args <= 1 ? args[0] : args)
                end
                
              else
                break unless found.possible?(command_args + [curr])
                command_args << curr
              end

              inc
            end
            dec

            unless found.valid?(command_args)
              raise MissingArgumentError.new(found, command_args, found.opts)
            end

            if found.block?
              found.run(state[found.name], command_args)
            else
              state[found.name][:args] = (found.max_args <= 1 ? command_args[0] : command_args)
            end

            @debug_padding = ""

          # otherwise it is an option
          else
            debug "Found option:  #{found}"
            args = found.max_args > 0 ? do_arguments_for(found) : [true]

            if found.block?
              found.run(state, args)
            else
              state[found.name] = (found.max_args <= 1 ? args[0] : args)
            end
          end

        elsif curr[0..4] == '--no-'
          found = @base.find("--#{curr[5..-1]}")
          debug "Found argument: #{found} (false)"

          if found.block?
            found.run(state, [false])
          else
            state[found.name] = false
          end

        elsif curr[0] == '-' && curr.size > 2 && @base.has?("-#{curr[1]}")
          currs = curr[1..-1].split('').map {|i| "-#{i}" }

          currs.each do |c|
            opt = @base.find(c)
            raise Parser::MissingOptionError.new(name) unless opt
            debug "Found option: #{opt}"

            if c == currs.last
              args = opt.max_args > 0 ? do_arguments_for(opt) : [true]

              if opt.block?
                opt.run(state, args)
              else
                state[opt.name] = (opt.max_args <= 1 ? args[0] : args)
              end
            else # can't take any arguments as an option is next to it
              if opt.max_args > 0
                raise MissingArgumentError.new(opt, [], opt.args)
              end

              if opt.block?
                opt.run(state, [true])
              else
                state[opt.name] = true
              end
            end
          end

        # otherwise it is an argument
        else
          debug "Found argument: #{curr}"
          arguments << curr
        end

        inc
      end

      return arguments, state
    end

    # Returns the finished argument list for +opt+ which can then be pushed to the state.
    def do_arguments_for(opt, buffer=0)
      arg_list = collect_arguments(opt, buffer)
      arg_list = validate_arguments(opt, arg_list)

      debug "  got #{arg_list.size} argument(s): #{arg_list.to_s[1..-2]}"

      arg_list
    end

    def collect_arguments(opt, buffer=0)
      inc
      arg_list = []
      while i < (argv.size - buffer) && arg_list.size < opt.max_args
        break unless opt.possible?(arg_list + [curr])
        arg_list << curr
        inc
      end
      dec
      arg_list
    end

    def validate_arguments(opt, arg_list)
      # If we don't have enough args
      unless opt.valid?(arg_list)
        raise MissingArgumentError.new(opt, arg_list, opt.args.join(' ').gsub('] [', ' '))
      end

      opt.valid_arg_list(arg_list)
    end

  end
end
