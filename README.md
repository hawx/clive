# clive

Clive is a DSL for creating a command line interface. It is for people who, like me, love [OptionParser's](http://ruby-doc.org/stdlib/libdoc/optparse/rdoc/classes/OptionParser.html) syntax and love [GLI's](http://github.com/davetron5000/gli) commands.

## Install

Install with:
    
    (sudo) gem install clive
    

## How To

A simple example to start:

    require 'clive'
    
    opts = {}
    c = Clive.new do
      switch(:v, :verbose, "Run verbosely") {opts[:verbose] = true}
    end
    c.parse(ARGV)
    p opts

This creates a very simple interface which can have one switch, you can then use the long or short form to call the block.

    my_file -v
    #=> {:verbose => true}
    my_file --verbose
    #=> {:verbose => true}
    

### Switches

As we've seen above switches are created using #switch. You can provide as little information as you want. `switch(:v) {}` creates a switch that responds only to `-v`, or `switch(:verbose) {}` creates a switch that only responds to `--verbose`.

### Boolean

Boolean switches allow you to accept arguments like `--no-verbose` and `--verbose`, and deal with both situations in the same block.

    c = Clive.new do
      boolean(:v, :verbose) {|i| p i}
    end
    c.parse(ARGV)
    
    ####
    
    my_file --verbose
    #=> true
    my_file -v
    #=> true
    my_file --no-verbose
    #=> false

As you can see the true case can be triggered with the short or long form, the false case can be triggered by appending "no-" to the long form, and it can't be triggered with a short form.

### Flags

Flags are like switches but also take an argument:

    c = Clive.new do
      flag(:p, :print, "ARG", "Print ARG") do |i|
        p i
      end
    end
    c.parse(ARGV)
    
    ####
    
    my_file --print=hello
    #=> "hello"
    my_file --print equalsless
    #=> "equalsless"
    my_file -p short
    #=> "short"

The argument is then passed into the block. As you can see you can use short, long, equals, or no equals to call flags. As with switches you can call `flag(:p) {|i| ...}` which responds to `-p ...`, `flag(:print) {|i| ...}` which responds to `--print ...` or `--print=...`.
Flags can have default values, for that situation put square brackets round the argument name.

    flag(:p, :print, "[ARG]", "Print ARG or "hey" by default) do |i|
      i ||= "hey"
      p i
    end

### Commands

Commands work like in git, here's an example:
    
    opts = {}
    c = Clive.new do
      command(:add) do
        opts[:add] = {}
        flag(:r, :require, "Require a library") {|i| opts[:add][:lib] = i}
      end
    end
    c.parse(ARGV)
    p opts
    
    ####
    
    my_file add -r Clive
    #=> {:add => {:lib => "Clive"}}

Commands make it easy to group flags, switches and even other commands. The block for the command is executed on finding the command, this allows you to put other code within the block specific for the command, as shown above.


### Arguments

Anything that isn't a command, switch or flag is taken as an argument. These are returned by #parse as an array. 
    
    opts = {}
    c = Clive.new do
      flag(:size) {|i| opts[:size] = i}
    end
    args = c.parse(ARGV)
    p args
    
    ####
    
    my_file --size big /usr/bin
    #=> ["/usr/bin"]

### Putting It All Together

    require 'clive'
    
    opts = {}
    c = Clive.new do
      switch(:v, :verbose, "Run verbosely") {opts[:verbose] = true}
      
      command(:add, "Add a new project")) do
        opts[:add] = {}
        
        switch(:force, "Force overwrite") {opts[:add][:force] = true}
        flag(:framework, "Add framework") do |i| 
          opts[:add][:framework] ||= []
          opts[:add][:framework] << i
        end
        
        command(:init, "Initialize the project after creating") do
          switch(:m, :minimum, "Use minimum settings") {opts[:add][:min] = true}
          flag(:width) {|i| opts[:add][:width] = i.to_i}
        end
      
      end
      
      switch(:version, "Show version") do
        puts "1.0.0"
        exit
      end
    end
    args = c.parse(ARGV)
    p opts
    p args
    
    ####
    
    my_file --version
    #=> 1.0.0
    my_file -v add --framework=blueprint init -m -w 200 ~/Desktop/new_thing ~/Desktop/another_thing
    #=> {:verbose => true, :add => {:framework => ["blueprint"], :min => true, :width => 200}}
    #=> ["~/Desktop/new_thing", "~/Desktop/another_thing"]

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
