# This should control the character output to the command line.
# It will allow you to set different colours, using:
#
#   "I'm red".red
#   "I'm red and bold".red.bold
#
#

class Clive
  module Output
  
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
    
    # Light white doesn't exist
    unless name == "white"
      # Change name to grey instead of l_black
      _name = "l_#{name}"
      if name == "black"
        _name = "grey"
      end
      
      define_method "#{_name}" do
        colour("\e[9#{code}m")
      end
      
      define_method "#{_name}_bg" do
        colour("\e[10#{code}m")
      end
    end
  end

end

