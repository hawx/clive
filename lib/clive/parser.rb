module Clive

  class Parser

    class MissingArgumentError < Error
      reason 'missing argument for #0, found #1, needed #2'
    end
    
    class MissingOptionError < Error
      reason 'option could not be found: #0'
    end

    # :state [.new, #[], #[]=] Used to store values from options that do not trigger blocks.
    # :debug [Boolean] Whether to print debug messages, useful if parsing oddly.
    DEFAULTS = {
      :state => ::Hash,
      :debug => false
    }

    def initialize(base)
      @base = base
    end

    # The parser should work how you expect. It allows you to put global options before and after
    # a command section (if it exists, which it doesn't), so you have something like.
    #
    #    my_app.rb [global options] ([command] [options] [args]) [g. options] [g. args] [g. options] etc.
    #            |  global section  |    command section       |      global section
    #
    # Only one command can be run, if you attempt to use two the other will be caught as an argument.
    #
    def parse(argv, pre_state, opts={})
      @argv = argv
      @opts = DEFAULTS.merge(opts)
      @i = 0

      @arguments   = []
      @state       = @opts[:state].new
      pre_state.each {|k,v| @state[k] = v }
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
            
            @state[found.name] = found.run_block(@opts[:state].new)

            debug "Found command: #{found}"
            @debug_padding = "  "

            inc
            
            command_args = []

            until ended?
              if found.has?(curr)
                opt = found.find(curr)
                debug "Found option: #{opt}"
                
                args = opt.max_args > 0 ? do_arguments_for(opt) : [true]

                if opt.block?
                  opt.run(@state[found.name], args)
                else
                  @state[found.name][opt.name] = (opt.max_args <= 1 ? args[0] : args)
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
            
            found.run(@state[found.name], command_args)
            @debug_padding = ""

          # otherwise it is an option
          else
            debug "Found option: #{found}"
            args = found.max_args > 0 ? do_arguments_for(found) : [true]
            found.run(@state, args)
          end

        elsif curr[0..4] == '--no-'
          found = @base.find("--#{curr[5..-1]}")
          debug "Found argument: #{found} (false)"
          found.run(@state, [false])

        elsif curr[0..0] == '-' && curr.size > 2 && @base.has?("-#{curr[1..1]}")
          currs = curr[1..-1].split('').map {|i| "-#{i}" }

          currs.each do |c|
            opt = @base.find(c)
            raise Parser::MissingOptionError.new(name) unless opt
            debug "Found option: #{opt}"

            if c == currs.last
              args = opt.max_args > 0 ? do_arguments_for(opt) : [true]
              
              opt.run(@state, args)
            else # can't take any arguments as an option is next to it
              if opt.max_args > 0
                raise MissingArgumentError.new(opt, [], opt.args)
              end
              
              opt.run(@state, [true])
            end
          end

        # otherwise it is an argument
        else
          debug "Found argument: #{curr}"
          @arguments << curr
        end

        inc
      end

      return @arguments, @state
    end
    

    private
    
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

    # Print a debugging statement if running in debug mode.
    def debug(str)
      puts @debug_padding.to_s + str.l_cyan if @opts[:debug]
    end

    # Returns the finished argument list for +opt+ which can then be pushed to the state.
    def do_arguments_for(opt, buffer=0)
      arg_list = collect_arguments(opt, buffer)
      arg_list = validate_arguments(opt, arg_list)
      
      debug "  got #{arg_list.compact.size} argument(s): #{arg_list.inspect}"

      arg_list
    end

    # Collects the arguments for +opt+.
    def collect_arguments(opt, buffer=0)
      inc
      arg_list = []
      while @i < (@argv.size - buffer) && arg_list.size < opt.max_args
        break unless opt.possible?(arg_list + [curr])
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
      unless opt.valid?(arg_list)
        raise MissingArgumentError.new(opt, arg_list, opt.args.to_s)
      end

      opt.valid_arg_list(arg_list)
    end

  end
end
