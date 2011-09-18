require_relative '../lib/clive'

# see http://ruby-doc.org/stdlib/libdoc/optparse/rdoc/classes/OptionParser.html
class CLI
  extend Clive

  CODES = %w[iso-2022-jp shift_jis euc-jp utf8 binary]
  CODE_ALIASES = { "jis" => "iso-2022-jp", "sjis" => "shift_jis" }
  
  header 'Usage: example.rb [options]'
  
  group 'Specific options'
  
  desc 'Require the LIBRARY before executing your script'
  opt :r, :require, arg: '<LIBRARY>' do |lib|
    set(:library, get(:library) << lib)
  end
  
  desc 'Edit ARGV files in place (make backup if EXTENSION supplied)'
  opt :i, :inplace, arg: '[<EXTENSION>]' do |ext|
    set :inplace, true
    set :extension, (ext || '').sub!(/\A\.?(?=.)/, ".") # Ensure extension begins with dot.
  end
  
  desc 'Delay N seconds before executing'
  opt :delay, arg: '<N>', as: Float
  
  desc 'Begin executaion at given time'
  opt :t, :time, arg: '<Time>', as: Time
  
  desc 'Example "list" of arguments'
  opt :list, arg: '<list>', as: Array
  
  desc 'Select encoding'
  opt :code, arg: '<CODE>', in: (CODE_ALIASES.keys + CODES) do |code|
    set :encoding, code
  end
  
  desc 'Select transfer type'
  opt :type, arg: '<TYPE>', in: [:text, :binary, :auto], as: Symbol do |t|
    set :transfer_type, t
  end
  
  group 'Common options'
  
  opt :v, :verbose, 'Run verbosely', as: Boolean
  
  opt :version, 'Show version', :tail => true do
    puts Clive::VERSION
    exit
  end

end

args, opts = CLI.run(ARGV, :help_command => false)
p opts

__END__

# Differences

Clive doesn't have:
- completion support, work on that too
