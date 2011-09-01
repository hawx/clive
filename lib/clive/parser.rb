module Clive

<<<<<<< HEAD
  # A module wrapping the command line parsing of clive. In the future this
  # will be the only way of using clive.
  #
  # @example
  #
  #   require 'clive'
  # 
  #   class CLI
  #     include Clive::Parser
  #     option_hash :opts
  #   
  #     switch :v, :verbose, "Run verbosely" do
  #       opts[:verbose] = true
  #     end
  #   end
  #
  #   CLI.parse ARGV
  #   p CLI.opts
  #
  module Parser
    def self.included(klass)
      klass.include(Clive)
    end
  end


  # Parse is the parser for command line input it takes the input and all
  # commands, flags, switches, etc and then sorts it out
  class Parse
    
    # @param argv [Array] The passed command line input, usually ARGV
    # @param klass [Command] The command being run in
    def initialize(argv, klass)
      @argv     = argv
      @klass    = klass
    end
    
    # @return [Array] all bools in this command
    def bools
      @klass.options.find_all {|i| i.class == Bool }
    end
    
    # @return [Array] all switches in this command
    def switches
      @klass.options.find_all {|i| i.class == Switch }
    end
    
    # @return [Array] all flags in this command
    def flags
      @klass.options.find_all {|i| i.class == Flag }
    end
    
    # Finds the command which has the name given
    #
    # @param name [String]
    # @return [Clive::Command]
    #
    def find_command(str)
      @klass.commands.find {|i| i.names.include?(str)}
    end
    
    # Finds the option which has the name given
    #
    # @param name [String]
    # @return [Clive::Option]
    #
    def find_opt(name)
      @klass.options.find {|i| i.names.include?(name)}
    end
    
    def opt_type(name)
      case find_opt(name).class.name
      when "Clive::Switch"
        :switch
      when "Clive::Bool"
        :switch
      when "Clive::Flag"
        :flag
      when "Clive::Command"
        :command
      else
        #raise "'#{name} (#{find_opt(name).class.name})' not of recognised type"
        nil
      end
    end
    
    
    def tokenise(arr=@argv)
      r = []
      
      arr.each do |a|
        case a
        when /\-\-(.+)/
          r << [:option, $1]
        when /\-(.+)/
          r += $1.split('').map {|i| [:option, i] }
        else
          r << [:word, a]
        end
      end
      
      r
    end
    
    
    def _populate(arr=tokenise)
      tree = []
      _temp = []
      
      arr.each_with_index do |(t,v), i|
        last = tree[i-1] || []
        last[2] ||= [] if last[0] == :flag
        
        case t
        when :word
          if command = find_command(v)
            if last[0] == :flag
              if last[2].size < last[1].arg_size(:mandatory)
                last[2] << [:arg, v]
              else
                tree << [:command, command, populate(arr[i+1..-1])]
                break
              end
            else
              tree << [:command, command, populate(arr[i+1..-1])]
              break
            end
            
          else
            if last[0] == :flag && last[2].size < last[1].arg_size(:all)
              _temp << [:arg, v]
            else
              tree << [:arg, v]
            end
          end
          
        when :option
          tree << [opt_type(v), find_opt(v)]
        end
        
        unless _temp.empty?
          tree += _temp
          _temp = []
        end
      end
      
      tree
    end
    
    def populate(arr=tokenise)
      tree = []
      
      i = 0
      arr.each_with_index do |(t,v), i|
        p t
        if t == :word
          last = tree.last || []
          last[2] ||= [] if last[0] == :flag
          
          if command = find_command(v)
            if last[0] == :flag              
              if last[2].size < last[1].arg_size(:mandatory)
                last[2] << [:arg, v]
              else
                tree << [:command, command, populate(arr[i+1..-1])]
                break
              end
            else
              tree << [:command, command, populate(arr[i+1..-1])]
             break
            end
            
          else
            if last[0] == :flag && last[2].size < last[1].arg_size(:all)
              last[2] << [:arg, v]
            else
              tree << [:arg, v]
            end  
          end
          
        else
          tree << [opt_type(v), find_opt(v)]
        end
  
        i += 1
      end
  
      tree
    end
    
    
    # Traverses the tree created by #tokens_to_tree and runs the correct options.
    # 
    # @param tree [Array]
    # @return [Array]
    #   Any unused arguments.
    #
    def run_tree(tree=populate)
      i = 0
      l = tree.size
      r = []
      
      while i < l
        curr = tree[i]
        
        case curr[0]
        when :command
          r << curr[1].run(curr[2])
          
        when :switch
          curr[1].run
          
        when :flag
          args = curr[2].map {|i| i[1] }
          if args.size < curr[1].arg_size(:mandatory)
            raise MissingArgument.new(curr[1].sort_name)
          end
          curr[1].run(args)
          
        when :arg
          r << curr[1]
        end
        
        i += 1
      end
      r.flatten
    end
    
    
  end
end

$: << File.dirname(__FILE__) + '/..'
require 'clive'

=======
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

      until ended?
        # does +curr+ exist? (and also check that if it is a command a command hasn't been run yet
        if @base.has?(curr) && ((@base.find(curr).command? && !command_ran) || (@base.find(curr).option?))
        
          found = @base.find(curr)

          # is it a command?
          if found.command?
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
        raise MissingArgumentError.new(opt, arg_list, opt.args)
      end

      opt.valid_arg_list(arg_list)
    end
>>>>>>> master

class CLI
  include Clive
  
  desc 'Save the file'
  flag :s, :save, :arg => 'FILENAME' do |i|
    puts "Saving #{i}"
  end
  
  command :new, 'Create new something' do
    switch :v do
      puts "Verbose mode"
    end
  end
end

# [
#   [:command, "new", [
#     [:switch, "s"],
#     [:arg, "what"]]
# ]

$ran ||= false
unless $ran == true
  #parse = Clive::Parse.new(%w(new -v), CLI)
  #p parse.tokenise
  # p parse._populate
  #p parse.populate
  #p parse.run_tree
  CLI.parse
  
  $ran = true
end

