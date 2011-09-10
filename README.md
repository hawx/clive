# clive

Clive is a DSL for creating command line interfaces.

## Install

Install with:
    
    gem install clive
    

## Usage

__NOTE__: Throughout I will be using the new 1.9 `{a: b}` hash syntax, obviously the old
`{:a => b}` syntax still works and can be used if you want or where 1.8 compatibility is
needed.

Clive is built around the idea that it makes more sense to define a cli in a class,
this way it can be easily modified and reopened to add more options.

    # my_app.rb
    require 'clive'

    module MyApp
      VERSION = "0.1.4"
      
      # some code
      
      class CLI
        extend Clive
        
        opt :v, :version, 'Display the current version' do
          puts MyApp::Version
          exit 0
        end
        
      end
    end
    
    args, state = MyApp::CLI.run(ARGV)

Then run with `my_app.rb --version` to display the version for MyApp. `.run`
returns two arguments the first is an Array with all of the arguments that were 
not used; the second is a Hash, if any option is called which doesn't have a
block an entry is added with the name of the option and `true`.


### Options

Options are defined using `#opt` or `#option` they can have short ('-a') or long 
names ('--abc') and can also have arguments. The description can be given as an
argument to `#opt` or can be defined before it using `#desc`.

    opt :v, :version, 'Display the current version' do
      # ...
    end
    
    # is equivelant to
    
    desc 'Display the current version'
    opt :v, :version do
      # ...
    end

Boolean options can be created by passing `as: Boolean` in the call to `#opt`.

    opt :a, :auto, as: Boolean

This could be called with `-a` or `--auto` returning a state of `{:auto => true}`,
or `--no-auto` returning a state of `{:auto => false}`.

Longer option names, with `_` are called by replacing the `_` with a `-` so

    opt :longer_name_than_expected

Would be called with `--longer-name-than-expected`.


### Arguments

Options can takes arguments by adding a hash with the key `:arg` or `:args`:

    opt :size, args: '<height> <width>'

The option size takes two arguments. These would be saved to state as an array, 
for instance running with `--size 10 40` would return a state of `{:size => 
['10', '40']}`.

Arguments can be made optional by enclosing one or more arguments with `[` and `]`:

    # both required
    opt :size, args: '<h> <w>'
    
    # first required
    opt :size, args: '<h> [<w>]'
    
    # second required
    opt :size, args: '[<h>] <w>'
    
    # neither required
    opt :size, args: '[<h> <w>]'

There are also various options that can be passed to constrain or change the 
arguments. When using these if `:arg` is not given it is inferred from the
options given.


#### Types
Aliased as `:type`, `:kind`, `:as`.

Allows you to say that an argument must be converted to a specific type before
use in a block or being saved to state, but also that it should look like a 
specific type.

    opt :list, as: Array

Accepts a comma delimeted list of items, `--list a,b,c` and returns them as
an Array (ie. `['a', 'b', 'c']`).

#### Matches
Aliased as `:match`.

Allows you to say that an argument must match a regular expression (or any object
which responds to `#match`).

    opt :word, match: /^\w+$/

Accepts `--word hello` but not `--word 123`.

#### Withins
Aliased as `':within`, `:in`.

Allows you to say that an argument must be within a passed Array, Set or Range
(any object which responds to `#include?`).

    opt :num, in: 1..100

Accepts `--num 50` but not `--num 900`.

#### Defaults
Aliased as `:default`.

Allows you to give a default value that should be used if an argument is not 
given. 

    opt :type, default: 'house'

So `--type` would return a state of `{:type => 'house'}` but `--type shed`
would return a state of `{:type => 'shed'}`.

#### Constraints
Aliased as `:constraint`.

Allows you to constrain the argument using a Proc, this is to cover the very
few events where the above options do not satisfy the requirements.

    opt :long_word, constraint: -> {|i| i.size >= 7 }

Accepts `--long-word eventually` but not `--long-word even`.


### Commands

Commands can be defined using `#command`, they can contain other Options allowing
you to namespace functionality. Commands are like Options in that they can take
arguments, but they do not have short and long names, instead they can be given
as many names as you wish. 

    command :new, :create, 'Creates a new project', arg: '<dir>', as: Pathname do
    
      desc 'Use basic, complex or custom template from ~/.templates'
      opt :type, arg: '<choice>', in: %w(basic complex custom), default: :basic, as: Symbol
      
      opt :force, 'Force overwrite' do
        require 'highline/import'
        answer = ask "Are you sure, this could delete stuff? [y/n]\n"
        set :force, true if answer == "y"
      end
      
      action do
        puts "Creating #{get :type} in #{dir}"
        # write stuff
      end
    end

This shows a fairly complex command. It can be called with `new` or `create` and takes
one argument a directory which is converted to a Pathname object. Inside two Options
are defined; `--type` which takes one of a selection of options but has a default set.
And `--force` which asks for confirmation before using the `#set` method to set a value 
in the state. Then an action is defined below which prints a message using `#get` to 
retrieve a value from the state and then using the argument passed to the command. 

If called with `new --type complex --force ~/projects/first` and then typed 'y' when 
prompted, the message `"Creating complex in ~/projects/first"` would be printed and the 
state returned would be `{:type => :complex, :force => true}`.


## Clive::Output

This is a new bit that allows you to colourise output from the command line, by patching a 
few methods onto String.

    require 'clive/output'
    # or require 'clive'
    
    puts "I'm blue".blue                     # will print blue text
    puts "I'm red".red                       # will print red text
    puts "I'm green and bold".green.bold     # will print green and bold text
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
 - black (light version called grey not l\_black)
 
 - + light versions of colours using l\_colour)
 - + background setters using colour\_bg
 - + light background using l\_colour\_bg
 


## Copyright

Copyright (c) 2010 Joshua Hawxwell. See LICENSE for details.
