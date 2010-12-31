# clive

Clive is a DSL for creating a command line interface. It is for people who, like me, 
love [OptionParser's](http://ruby-doc.org/stdlib/libdoc/optparse/rdoc/classes/OptionParser.html) syntax and love [GLI's](http://github.com/davetron5000/gli) commands.

## Install

Install with:
    
    (sudo) gem install clive
    

## How To

Simply include `Clive::Parser` to start using.
A simple example:
    
    # test.rb
    require 'clive'
    
    class CLI
      include Clive::Parser
      option_hash :config
      
      desc 'Run verbosely'
      switch :v, :verbose do
        config[:verbose] = true
      end
      
    end
    CLI.parse(ARGV)
    p CLI.config

This creates a very simple interface which can have one switch, you can then use the 
long or short form to call the block.

    test.rb -v
    #=> {:verbose => true}
    test.rb --verbose
    #=> {:verbose => true}
    

### Switches

The most basic options. When they are called by either name the block is run. To create
a switch use `#switch`.

    switch :s do
      # code
    end
    # Called with '-s'
    
    switch :long do
      # code
    end
    # Called with '--long'
    
    switch :b, :both do
      # code
    end
    # Called with '-b' or '--both'


### Booleans

Boolean switches allow you to easily create a pair of switches, eg. `--force` and 
`--no-force`. The block given is passed either true or false depending on which was 
used.

    bool :f, :force do |truth|
      p truth
    end
    # '-f' returns true
    # '--force' returns true
    # '--no-force' returns false

You must provide a long name, a short name is optional.


### Flags

Flags are like switches but take one or more arguments, these are then passed to the 
block.

    # Creates a flag with a mandatory argument
    flag :with, :args => "ARG" do |arg|
      puts arg
    end
    
    # Creates a flag with an optional argument, by using []
    flag :with, :args => "[ARG]" do |arg|
      puts arg
    end
    
    # Creates a flag with multiple arguments
    flag :with, :args => "FIRST [OPTIONAL]" do |i, j|
      puts i, j
    end

You can also provide a list of options to select from.
    
    flag :choose, :args => %w(small med large) do |choice|
      puts choice
    end
    
    flag :number, :args => 1..5 do |num|
      puts num
    end
    

### Commands 

Commands allow you to group a collection of options (or more commands) under a keyword.
The block provided is run when one of the names for the command is encountered, but the
blocks of the options in it are only ran when they are found.

    command :init, :create do
      bool :force do |truth|
        puts "Force"
      end
    end
    # 'init --force'
    

### Arguments

Anything that is not captured as a command, option or argument of a flag, is returned by
#parse in an array.

    class Args
      include Clive::Parser
      
      switch(:hey) { puts "Hey" }
    end
    args = Args.parse(ARGV)
    p args
    
    # `file --hey argument "A string"`
    #=> ['argument', 'A string']


### Option Handling

You are able to intercept errors when an option does not exist in a similar way to 
`method_missing`.

    class Missing
      option_missing do |name|
        puts "#{name} was used but not defined"
      end
    end
    Missing.parse %w(--hey)
    #=> hey was used but not defined


### Help Formatting

There are two built in help formats the default, with colour, and a pure white one. To 
change the formatter call `#help_formatter` with :default, or :white.

Optionally you can create your own formatter, like so:

    class CLI
      help_formatter do |h|
        h.switch "{prepend}{names.join(', ')} {spaces}# {desc}"
        h.bool   "{prepend}{names.join(', ')} {spaces}# {desc}"
        h.flag   "{prepend}{names.join(', ')} {args.join(' ')} {spaces}# {desc}" <<
                   "{options.join('(', ', ', ')')}"
        h.command "{prepend}{names.join(', ')} {spaces}# {desc}"
      end
    end

Which would look like:

    Usage: my_app [command] [options]
    
      Commands:
        test            # A command
        
      Options:
        -h, --help      # Display help
        --[no-]force    # Force build

You have access to the variables:

* prepend - a string of spaces as specified when `#help_formatter` is called
* names - an array of names for the option
* spaces - a string of spaces to align the descriptions properly
* desc - a string of the description for the option

And for flags you have access to:

* args - an array of arguments for the flag
* options - an array of options to choose from

Inside the { and } you can put any ruby, so feel free to use joins on the array.

 
## Clive::Output

This is a new bit that allows you to colourise output from the command line, by patching a 
few methods onto String.

    require 'clive/output'
    # or require 'clive'
    
    puts "I'm blue".blue  # will print blue text
    puts "I'm red".red    # will print red text
    puts "I'm green and bold".green.bold   # will print green and bold text
    puts "Crazy".blue.l_yellow_bg.underline
    # etc

Methods available are:
 - bold
 - underline
 - blink
 - reverse
 
 - white
 - green
 - red
 - magenta
 - yellow
 - blue
 - cyan
 - black (light version called grey not l_black)
 
 - + light versions of colours using l_colour)
 - + background setters using colour_bg
 - + light background using l_colour_bg

    

## Note on Patches/Pull Requests
 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself so I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright (c) 2010 Joshua Hawxwell. See LICENSE for details.
