$: << File.dirname(__FILE__) + '/..'
require 'helper'

describe 'A CLI' do
  subject { 
    Class.new {
      extend Clive
      
      header 'Usage: clive_test.rb [command] [options]'
      
      opt :version, :tail => true do
        puts "Version 1"
      end
      
      set :something, []
      
      bool :v, :verbose
      bool :a, :auto
      
      opt :s, :size, 'Size of thing', :arg => '<size>', :as => Float
      opt :S, :super_size
      
      opt :name, :args => '<name>'
      opt :modify, :arg => '<key> <sym> [<args>]', :as => [Symbol, Symbol, Array] do
        update key, sym, *args
      end
        
      desc 'Print <message> <n> times'
      opt :print, :arg => '<message> <n>', :as => [String, Integer] do
        n.times { puts message }
      end
      
      desc 'A super long description for a super stupid option, this should test the _extreme_ wrapping abilities as it should all be aligned. Maybe I should go for another couple of lines just for good measure. That\'s all'
      opt :complex, :arg => '[<one>] <two> [<three>]', :match => [ /^\d$/, /^\d\d$/, /^\d\d\d$/ ] do |a,b,c|
        puts "a: #{a}, b: #{b}, c: #{c}"
      end
      
      command :new, :create, 'Creates new things', :arg => '[<dir>]', :match => /\// do
    
        set :something, []
    
        # implicit arg as "<choice>", also added default
        opt :T, :type, :in => %w(post page blog), :default => :page, :as => Symbol
        opt :force, 'Force overwrite' do
          require 'highline/import'
          answer = ask("Are you sure, this could delete stuff? [y/n]\n")
          set :force, true if answer == "y"
        end
      
        action do |dir|
          puts "Creating #{get :type} in #{dir}" if dir
        end
      end
    }
  }
  
  describe '--version' do
    it 'prints version string' do
      this {
        subject.run s '--version'
      }.must_output "Version 1\n"
    end
  end
  
  describe 'set :something' do
    it 'is set to an empty Array' do
      a,s = subject.run []
      s[:something].must_equal []
    end
  end
  
  describe '-a, --[no-]auto' do
    it 'sets to true' do
      a,s = subject.run s '--auto'
      s[:auto].must_be_true
      s[:a].must_be_true
    end
    
    it 'sets to false if no passed' do
      a,s = subject.run s '--no-auto'
      s[:auto].must_be_false
      s[:a].must_be_false
    end
    
    it 'allows the short version' do
      a,s = subject.run s '-a'
      s[:auto].must_be_true
      s[:a].must_be_true
    end
  end
  
  describe '-s, --size' do
    it 'takes a Float as an argument' do
      a,s = subject.run s '--size 50.56'
      s[:size].must_equal 50.56
      s[:s].must_equal 50.56
    end
    
    it 'raises an error if the argument is not passed' do
      this {
        subject.run s '--size'
      }.must_raise Clive::Parser::MissingArgumentError
    end
    
    it 'raises an error if a Float is not given' do
      this {
        subject.run s '--size hello'
      }.must_raise Clive::Parser::MissingArgumentError
    end
  end
  
  describe '-S, --super-size' do
    it 'can be called with dashes' do
      a,s = subject.run s '--super-size'
      s[:super_size].must_be_true
      s[:S].must_be_true
    end
    
    it 'can be called with underscores' do
      a,s = subject.run s '--super_size'
      s[:super_size].must_be_true
      s[:S].must_be_true
    end
  end
  
  describe '--modify' do
    it 'updates the key' do
      a,s = subject.run s '--name "John Doe" --modify name count oe,e'
      s[:name].must_equal 1
    end
  end
  
  describe '--print' do
    it 'prints a message n times' do
      this {
        subject.run s '--print "Hello World!" 5'
      }.must_output ("Hello World!\n" * 5)
    end
  end
  
  describe '--complex' do
    it 'takes one argument' do
      this {
        subject.run s '--complex 55'
      }.must_output "a: , b: 55, c: \n"
      
      this {
        subject.run s '--complex 4'
      }.must_raise Clive::Parser::MissingArgumentError
      
      this {
        subject.run s '--complex 666'
      }.must_raise Clive::Parser::MissingArgumentError
    end
    
    it 'takes two arguments' do
      this {
        subject.run s '--complex 4 55'
      }.must_output "a: 4, b: 55, c: \n"
      
      this {
        subject.run s '--complex 55 666'
      }.must_output "a: , b: 55, c: 666\n"
      
      this {
        subject.run s '--complex 4 666'
      }.must_raise Clive::Parser::MissingArgumentError
    end
    
    it 'takes three arguments' do
      this {
        subject.run s '--complex 4 55 666'
      }.must_output "a: 4, b: 55, c: 666\n"
    end
  end
  
  describe 'new' do
    describe 'set :something' do
      it 'sets :something in :new to []' do
        a,s = subject.run s 'new'
        s[:new][:something].must_equal []
      end
    end
    
    describe '-T, --type' do
      it 'sets the type' do
        a,s = subject.run s 'new --type blog'
        s[:new][:type].must_equal :blog
        s[:new][:T].must_equal :blog
      end
      
      it 'uses the default' do
        a,s = subject.run s 'new --type'
        s[:new][:type].must_equal :page
        s[:new][:T].must_equal :page
      end
      
      it 'ignores non valid options' do
        a,s = subject.run s 'new --type crazy'
        s[:new][:type].must_equal :page
        s[:new][:T].must_equal :page
        a.must_equal ['crazy']
      end
    end
    
    describe '--force' do
      #it 'asks for conformation' do
      #  a,s = subject.run s 'new --force'
      #  s[:force].must_be_true
      #end
    end
    
    describe 'action' do
      it 'prints the type and dir' do
        this {
          subject.run s 'new --type ~/dir'
        }.must_output "Creating page in ~/dir\n"
      end
      
      it 'only accepts directories' do
        this {
          subject.run s 'new not-a-dir'
        }.must_output ""
      end
    end
  end
  
  it 'should be able to do this' do
    this {
      a,s = subject.run s('-v new --type post ~/my_site --no-auto arg arg2')
      a.must_equal %w(arg arg2)
      s.must_equal :something => [], :verbose => true, 
                   :new => {:something => [], :type => :post}, :auto => false
    }.must_output "Creating post in ~/my_site\n"
  end
  
  it 'should be able to do combined short switches' do
    a,s = subject.run s '-vas 2.45'
    
    s.to_hash.must_equal :something => [], :verbose => true, :auto => true, :size => 2.45
    s.aliases.must_equal :v => :verbose, :a => :auto, :s => :size
    
    this {
      subject.run %w(-vsa 2.45)
    }.must_raise Clive::Parser::MissingArgumentError
  end
end
