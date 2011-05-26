module Clive

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

