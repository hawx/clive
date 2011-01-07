module Clive
  
  # The formatter controls formatting of help. It can be configured
  # using Clive::Command#help_formatter.
  class Formatter
  
    class Obj
      def initialize(args)
        args.each do |k, v|
          self.class.send(:define_method, k) { v }
        end
      end
      
      # Evaluate the code given within the Obj created.
      def evaluate(code)
        eval(code)
      end
    end
  
    # Sizes
    attr_accessor :width, :prepend
  
    def initialize(width, prepend, &block)
      @width = width
      @prepend = prepend
    end
    
    
    def format(header, footer, commands, options)
      result = ""
    
      switches = options.find_all {|i| i.class == Clive::Switch }.map(&:to_h)
      bools    = options.find_all {|i| i.class == Clive::Bool }.map(&:to_h).compact
      flags    = options.find_all {|i| i.class == Clive::Flag }.map(&:to_h)
      commands = commands.map(&:to_h)
      
      result << header << "\n" if header
      
      unless commands.empty?
        result << "\n  Commands: \n"
        
        commands.each do |hash|
          hash['prepend'] = " " * @prepend
          result << parse(@command, hash) << "\n"
        end
      end
      
      
      unless options.empty?
        result << "\n  Options: \n"
      
        switches.each do |hash|
          hash['prepend'] = " " * @prepend
          result << parse(@switch, hash) << "\n"
        end
        
        bools.each do |hash|
          hash['prepend'] = " " * @prepend
          result << parse(@bool, hash) << "\n"
        end
        
        flags.each do |hash|
          hash['prepend'] = " " * @prepend
          result << parse(@flag, hash) << "\n"
        end
      end
      
      result << "\n" << footer << "\n" if footer
      
      result
    end
    
    
    def switch(format)
      @switch = format
    end
    
    def bool(format)
      @bool = format
    end
    
    def flag(format)
      @flag = format
    end
    
    def command(format)
      @command = format
    end
    
    def help(format)
      @help = format
    end
    
    def summary(format)
      @summary = format
    end
    
    
    def parse(format, args)
      front, back = format.split('{spaces}')
      
      front_p = parse_format(front, args)
      back_p  = parse_format(back, args) 
      
      s = @width - front_p.length
      s = 0 if s < 0 # can't have negative spaces!
      spaces = " " * s
      
      front_p << spaces << back_p
    end
    
    def parse_format(format, args)
      if format
        tokens = Lexer.tokenise(format).to_a
        obj = Obj.new(args)
        r = ""
        tokens.each do |(t,v)|
          case t
          when :block
            r << obj.evaluate(v)
          when :text 
            r << v
          end
        end
        r
      else
        ""
      end
    end
    
    class Lexer < Ast::Tokeniser
      rule :text, /%(.)/ do |i|
        i[1]
      end
    
      rule :block, /\{(.*?)\}/ do |i|
        i[1]
      end
      
      missing do |i|
        Ast::Token.new(:text, i)
      end
    end
  
  end
end
