require 'strscan'

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
        @scanner = StringScanner.new(format)
        result = []
  
        # Create object to eval in
        obj = Obj.new(args)
        
        until @scanner.eos?
          a = scan_block || a = scan_text
          result << a
        end
        
        r = ""
        result.each do |(t, v)|
          case t
          when :block # contains ruby to eval
            r << obj.evaluate(v)
          when :text # add this with no adjustment
            r << v
          end
        end
        r
      else
        ""
      end
    end
    
    
    # @group Scanning     
      def scan_block
        return unless @scanner.scan /\{/
        
        pos = @scanner.pos
        if @scanner.scan_until /\}/
          @scanner.pos -= @scanner.matched.size
          [:block, @scanner.pre_match[pos..-1]]
        end
      end
      
      def scan_text
        text = nil
        
        pos = @scanner.pos
        if @scanner.scan_until /(?<=[^\\])\{/
          @scanner.pos -= @scanner.matched.size
          text = @scanner.pre_match[pos..-1]
        end
        
        if text.nil?
          text = @scanner.rest
          @scanner.clear
        end
        
        # Remove }s from text
        if text[0] == "}"
          text = text[1..-1]
        end
        
        text.gsub!(/\\(.)/) {|m| m[1] }
                
        [:text, text]
      end
    # @endgroup
  
  end
end
