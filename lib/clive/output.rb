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
  
  {
    "bold"      => "1",
    "underline" => "4",
    "blink"     => "5",
    "white"     => "37",
    "green"     => "32",
    "red"       => "31",
    "magenta"   => "35",
    "yellow"    => "33",
    "blue"      => "34",
    "grey"      => "90"
  }.each do |name, code|
    define_method(name) do
      colour("\e[#{code}m")
    end
  end

end

