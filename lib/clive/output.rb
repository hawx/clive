module Clive
  module Output extend self
  
    def pad(str, len, with=" ")
      diff = len - str.clear_colours.size
      str += with * diff unless diff < 0
      str
    end

    # @param str [String] Text to be wrapped
    # @param left_margin [Integer] Width of space at left
    # @param width [Integer] Total width of text
    def wrap_text(str, left_margin, width)
      text_width = width - left_margin
      
      words = str.split(" ")
      r = [""]
      i = 0
      
      words.each do |word|
        if (r[i] + word).clear_colours.size < text_width
          r[i] << " " << word
        else
          i += 1
          r[i] = word
        end
      end
      
      # Clean up strings
      r.map! {|i| i.strip }
      
      ([r[0]] + r[1..-1].map {|i| l_pad(i, left_margin) }).join("\n")
    end
    
    # @return [Integer,nil] Width of terminal window, or +nil+ if it cannot be determined.
    # @see https://github.com/cldwalker/hirb/blob/v0.5.0/lib/hirb/util.rb#L61
    def terminal_width
      if (ENV['COLUMNS'] =~ /^\d+$/)
        ENV['COLUMNS'].to_i
      elsif (RUBY_PLATFORM =~ /java/ || (!STDIN.tty? && ENV['TERM'])) && command_exists?('tput')
        `tput cols`.to_i
      elsif STDIN.tty? && command_exists?('stty')
        # returns 'height width'
        `stty size`.scan(/\d+/).last.to_i
      else
        nil
      end
    rescue
      nil
    end
    
    
    private
    
    # Determines if a shell command exists by searching for it in ENV['PATH'].
    # @see https://github.com/cldwalker/hirb/blob/v0.5.0/lib/hirb/util.rb#L55
    def command_exists?(command)
      ENV['PATH'].split(File::PATH_SEPARATOR).any? {|d| File.exists? File.join(d, command) }
    end
  
    def l_pad(str, margin, with=" ")
      (with * margin) + str
    end
  
  end
end

# Monkey patches for colour
class String
  
  # @example
  #
  #   require 'clive/output'
  #
  #   puts "bold".bold
  #   puts "underline".underline
  #   puts "blink".blink
  #   puts "green".green
  #   puts "red".red
  #   puts "magenta".magenta
  #   puts "yellow".yellow
  #   puts "blue".blue
  #   puts "grey".grey
  #
  #   puts "combo".blue.bold.underline.blink
  #
  def colour(code)
    "#{code}#{self}\e[0m"
  end
  
  COLOURS = {
    "black"   => 0,
    "red"     => 1,
    "green"   => 2,
    "yellow"  => 3,
    "blue"    => 4,
    "magenta" => 5,
    "cyan"    => 6,
    "white"   => 7
  }
  
  ATTRIBUTES = {
    "bold"      => 1,
    "underline" => 4,
    "blink"     => 5,
    "reverse"   => 7
  }
  
  ATTRIBUTES.each do |name, code|
    define_method name do
      colour("\e[#{code}m")
    end
  end
  
  COLOURS.each do |name, code|
    define_method name do
      colour("\e[3#{code}m")
    end
    
    define_method "#{name}_bg" do
      colour("\e[4#{code}m")
    end
    
    # Change name to grey instead of l_black
    l_name = "l_#{name}"
    if name == "black"
      l_name = "grey"
    end
    
    define_method "#{l_name}" do
      colour("\e[9#{code}m")
    end
    
    define_method "#{l_name}_bg" do
      colour("\e[10#{code}m")
    end

  end
  
  def clear_colours
    gsub /\e\[?\d\d{0,2}m/, ''
  end
  
  def clear_colours!
    gsub! /\e\[?\d\d{0,2}m/, ''
  end
  
end
