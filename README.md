# clive

Clive is a DSL for creating command line interfaces.

## Install

Install with:
    
    gem install clive
    

## Usage

> __NOTE__: Throughout I will be using the new 1.9 `{a: b}` hash syntax, 
> obviously the old `{:a => b}` syntax still works and can be used if you want 
> or where 1.8 compatibility is needed. 

Clive is generally used by creating a class to hold your command line interface
as shown in the example below.

    # my_app.rb
    require 'clive'

    module MyApp
      VERSION = "0.1.4"
      
      # some code
      
      class CLI < Clive
        opt :v, :version, 'Display the current version' do
          puts MyApp::Version
          exit 0
        end
      end
    end
    
    result = MyApp::CLI.run(ARGV)

Then run with `my_app.rb --version` to display the version for MyApp. Sometimes
you may not want to create a class, instead you can simply create an instance of
Clive.

    result = Clive.new do
      opt :v, :version, 'Display the current version' do
        puts '1.0.0'
        exit 0
      end
    end.run(ARGV)    

Though the class style is preferred.


### `.run`

`.run` returns an instance of `Clive::StructHash` by default, this is a hybrid
hash and struct allowing you to access keys by calling them or using `#[]`. It
also stores any extra arguments that may have been passed which can be accessed
with `#args` or `#[:args]`.

    class CLI
      opt :n, :name, args: '<first> <last>'
      opt :age, arg: '<age>', as: Integer
    end
    
    result = CLI.run %w(--name John Doe --age 23 "I like coding!")
    
    bio  = result.args #=> "I like coding!"
    name = result.name #=> ['John', 'Doe']
    age  = result.age  #=> 23

This simple example shows how Clive can handle multiple arguments, casting to 
types (Integer in this case) and how extra arguments are stored in `#args`.


## Options

Options are defined using `#opt` or `#option` they can have short (`-a`) or long 
names (`--abc`) and can also have arguments. The description can be given as an
argument to `#opt` or can be defined before it using `#desc` (or `#description`).

    opt :v, :version, 'Display the current version' do
      # ...
    end
    
    # is equivalent to
    
    desc 'Display the current version'
    opt :v, :version do
      # ...
    end

Longer option names, containing `_`s are called by replacing the `_` with a `-` so

    opt :longer_name_than_expected

would be called with `--longer-name-than-expected`.

### Boolean Options

Boolean options are options which can be called with a `no-` prefix, which then
passes false to the block/state. For example,

    bool :a, :auto

Can be called with `-a` or `--auto` which would set `:auto` to `true`, or 
`--no-auto` which sets `:auto` to `false`. If a block is given you can retrieve
the truth by adding block parameters or using the `truth` variable which is 
automatically set.

    bool :a, :auto do |t|
      puts t
    end
    
    # OR
    
    bool :a, :auto do
      puts truth
    end

Boolean options __must__ have a long name.


## Commands

Commands can be defined using `#command`. They can be used to group related 
Options acting as a kind of namespace. But Commands are also fully featured 
Options so can take arguments as well. They can be created with multiple names.

    desc 'Create a new project'
    command :new, :create, arg: '<dir>', as: Pathname do
    
      # Set the default type to use
      set :type, :basic
    
      desc 'Select type of template to use'
      opt :type, arg: '<choice>', in: %w(basic complex custom), as: Symbol
      
      bool :force, 'Force overwrite'
      
      action do
        puts "Creating #{get :type} in #{dir}"
        # do writing
      end
    end

The above example also shows using the `#set` and `#get` methods, these allow
you to set and get values from the state. Also note how the logic for executing 
the `new` command is given to `#action`, this is because the block passed to 
`#command` is used for option definition.


## Arguments

As previously talked about Options and Commands can take arguments by passing a
hash with the key `:arg` or `:args`.

    opt :size, args: '<height> <width>'

The option `--size` takes two arguments. These would be saved to state as an array, 
for instance running with `--size 10 40` would set `:size` to `['10', '40']`.

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
arguments. If one of the below is passed to an option with `:arg` or `:args`
a generic argument called `<arg>` will be added.

### Types (`:types`, `:type`, `:kind` or `:as`)

An argument will be checked if it matches how the type should look, then converts
it to that type. For more information see `lib/clive/type/definitions.rb`.

    opt :list, as: Array

This accepts a comma delimited list of items, `--list a,b,c` and sets `:list` to
`['a', 'b', 'c']`.

### Matches (`:matches` or `:match`)

Allows you to say that an argument must match a regular expression (or any object
which responds to `#match`).

    opt :word, match: /^\w+$/

This accepts `--word hello` but not `--word 123`.

### Withins (`:withins`, `:within` or `:in`)

Allows you to say that an argument must be within a passed Array, Set or Range
(any object which responds to `#include?`).

    opt :num, in: "1".."100"

This accepts `--num 50` but not `--num 900`. The example above had to use a range
of Strings because that is what is passed, you can use this with `:type` to use
Integers.

    opt :num, as: Integer, in: 1..100

Would work in the same way as the one above but return an Integer.

### Defaults (`:defaults` or `:default`)

Allows you to give a default value that should be used if an argument is not 
given. 

    opt :type, default: 'house'

So `--type` would set `:type` to `'house'`, but `--type shed` would set `:type`
to `'shed'`. The default value is only set if the option is used. To set a value
regardless of whether the option is used use `#set` in the class or commands 
body.

    set :type, 'house'
    opt :type

Would always set `:type` to `'house'` even when `--type` is not used.

### Constraints (`:constraint` or `:constraint`)

Allows you to constrain the argument using a Proc, this is to cover the very
few events where the above options do not satisfy the requirements.

    opt :long_word, constraint: -> {|i| i.size >= 7 }

Accepts `--long-word eventually` but not `--long-word event`. You can also pass
a symbol which will have `#to_proc` called on it.

    opt :odd, as: Integer, constraint: :odd?

This only accepts odd Integers.


## Runner

All blocks passed to options or given to a command's action are run in the Runner
class. This provides a few shortcuts to make life easier. Here is a quick run down
with examples.

### Argument Referencing

You can reference an options or commands arguments directly by name without having
to use block parameters.

    opt :size, args: '<height> <width>', as: [Float, Float] do # no params!
      puts "Area = #{height} * #{width} = #{height * width}"
    end

As shown earlier the truthiness of a boolean option is set to the value `truth`.

### Working with the State

Four fundamental methods are defined for working with the state, `#get`, `#set`,
`#update` and `#has?`.

`#get` allows you to get values previously set.

    opt :get_some_key do
      puts get(:some_key) #=> value set for :some_key
    end

`#set` allows you to set values in the state.

    opt :set_some_key, arg: '<value>' do
      set :some_key, value
    end

`#update` allows you to modify a value in the state.

    set :list, []
    opt :add, arg: '<item>' do
      update :list, :<<, item
      
      # or using a block
      update(:list) {|l| l << item }
    end

`#has?` tells you whether a value has been set for the key.

    opt :has_some_key do
      puts has?(:some_key)
    end


## Help Formatters

Clive comes with two help formatters, one with colour and the other without. To use
the plain formatter (colour is default), use

    class CLI < Clive
      # ...
    end
    
    CLI.run ARGV, formatter: Clive::Formatter::Plain.new

To create your own formatter take a look at `lib/clive/formatter.rb`.


## Clive::Output

`clive/output` contains various monkey patches on String that allow you to easily 
colourise output.

    require 'clive/output'
    # or require 'clive'
    
    puts "I'm blue".blue                     # will print blue text
    puts "I'm green and bold".green.bold     # will print green and bold text
    puts "Crazy".blue.l_yellow_bg.underline
    # etc

Colours available: white, green, red, magenta, yellow, blue, cyan, black.
Effects available: bold, underline, blink, reverse.

Light versions can be used by prepending the name with `l_`, ie. `l_red`, the light
version of black is called grey.

All colours can be used as backgrounds by appending `_bg`, ie. `red_bg`, light 
backgrounds are as expected, `l_red_bg`.


## Copyright

Copyright (c) 2010-11 Joshua Hawxwell. See LICENSE for details.
