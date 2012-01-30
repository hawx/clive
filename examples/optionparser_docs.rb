require_relative '../lib/clive'

# This makes more sense if you read this side-by-side with the example of
# OptionParser linked below. That way you can see what the main differences are.
#
# http://ruby-doc.org/stdlib/libdoc/optparse/rdoc/classes/OptionParser.html

class CLI < Clive

  CODES = %w[iso-2022-jp shift_jis euc-jp utf8 binary]
  CODE_ALIASES = { "jis" => "iso-2022-jp", "sjis" => "shift_jis" }

  config :help_command => false, :help => false

  # We set default values here, unlike OptionParser the options are stored
  # internally and we have a specific method, #set, for setting them.
  set :library,        []
  set :inplace,        false
  set :encoding,       "utf8"
  set :transfer_type,  :auto
  set :verbose,        false

  header 'Usage: example.rb [options]'

  group 'Specific options'

  desc 'Require the LIBRARY before executing your script'
  opt :r, :require, arg: '<LIBRARY>' do |lib|
    # #update modifies a stored value, in this case +:library+ which was
    # previously set to +[]+ is appended (using #<<) with +lib+
    update :library, :<<, lib
    # the equivelant but more verbose version is
    # # update(:library) {|list| list << lib }
    # or even
    # # set :library, get(:library) << lib
  end

  desc 'Edit ARGV files in place (make backup if EXTENSION supplied)'
  opt :i, :inplace, arg: '[<EXTENSION>]' do |ext|
    set :inplace, true
    set :extension, ext || ''
    update :extension, :sub!, /\A\.?(?=.)/, '.'
    # This ensures extensino begins with a dot. It also shows off #update taking
    # more than one argument.
  end

  # The following three options can be written without bodies, but still keep
  # the same functionality as the versions in OptionParser

  desc 'Delay N seconds before executing'
  opt :delay, arg: '<N>', as: Float

  desc 'Begin executaion at given time'
  opt :t, :time, arg: '<TIME>', as: Time

  desc 'Specify record separator (default \0)'
  opt :F, :irs, arg: '<OCTAL>', as: Octal

  desc "Example 'list' of arguments"
  opt :list, arg: '<list>', as: Array


  # OptionParser allows completion here, Clive does not support completion, yet.
  desc 'Select encoding'
  opt :code, arg: '<CODE>', in: (CODE_ALIASES.keys + CODES) do |code|
    set :encoding, CODE_ALIASES[code] || code
  end

  desc 'Select transfer type'
  opt :type, arg: '<TYPE>', in: [:text, :binary, :auto], as: Symbol do |t|
    set :transfer_type, t
  end

  bool :v, :verbose, 'Run verbosely'

  group 'Common options'

  opt :version, 'Show version', :tail => true do
    puts Clive::VERSION
    exit
  end

  opt :h, :help, 'Display this help message', :tail => true do
    puts CLI.help
    exit
  end

end

r = CLI.run
p r.to_h
p r.args
