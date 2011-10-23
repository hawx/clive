$: << File.dirname(__FILE__) + '/..'
require 'helper'

describe Clive::Command do

  it 'can take arguments' do
    command = Clive::Command.new([], '', :arg => '<dir>')
    command.run_block
    
    state = {}
    command.run(state, ['~/somewhere'])
    state[:args].must_equal '~/somewhere'
  end
  
  it 'can run a block with arguments' do
    command = Clive::Command.new([], '', :arg => '<dir>') do
      action { puts dir }
    end
    command.run_block
    
    this { command.run({}, ['~/somewhere']) }.must_output "~/somewhere\n"
  end

  describe '#initialize' do
    before { 
      @command = Clive::Command.new([:c,:b,:a], 'A command', :head => true,
                                                             :args => '<a> [<b>]',
                                                             :as => [Integer, nil]) }
  
    it 'sets the names' do
      @command.names.must_equal [:a,:b,:c]
    end
    
    it 'sets the description' do
      @command.description.must_equal 'A command'
    end
    
    it 'sets the options' do
      @command.opts.must_equal({:head => true})
    end
    
    it 'sets the arguments' do
      @command.args.size.must_equal 2
      @command.args.map(&:name).must_equal [:a, :b]
    end
    
    it 'sets a default header' do
      # File.stub(:basename, '"file.rb"')
      @command.instance_variable_get(:@header).must_equal 'Usage: file.rb a,b,c [options]'
    end
    
    it 'sets a default footer' do
      @command.instance_variable_get(:@footer).must_equal ''
    end
    
    it 'adds the help option' do
      @command.must_be :has?, '--help'
      @command.must_be :has?, '-h'
    end
    
    it 'resets the current description' do
      @command.instance_variable_get(:@_last_desc).must_equal ''
    end
  end

  describe '#name' do
    it 'returns the first, alphabetically, name' do
      command = Clive::Command.new [:eee, :aaaaa, :aaa]
      command.name.must_equal :aaa
    end
  end

  describe '#to_s' do
    it 'returns the names joined' do
      command = Clive::Command.new [:a, :b, :c]
      command.to_s.must_equal 'a,b,c'
    end
  end

  describe '#run_block' do
    it 'runs the block passed to command' do
      command = Clive::Command.new do
        print 'Hey I was ran'
      end
      this { command.run_block({}) }.must_output 'Hey I was ran'
    end
    
    it 'returns a possibly modified state' do
      state = {}
      command = Clive::Command.new { set :a, true }
      state.wont_have :key?, :a
      command.run_block(state)
      state.must_have :key?, :a
    end
  end
  
  describe '#header' do
    it 'sets the header' do
      command = Clive::Command.new
      command.header 'A header'
      command.instance_variable_get(:@header).must_equal 'A header'
    end
  end

  describe '#footer' do
    it 'sets the footer' do
      command = Clive::Command.new
      command.footer 'A footer'
      command.instance_variable_get(:@footer).must_equal 'A footer'
    end
  end

  describe '#set' do
    it 'sets a value to the state hash' do
      command = Clive::Command.new
      command.instance_variable_set :@state, {}
      command.set :a, true
      command.instance_variable_get(:@state).must_equal({:a => true})
    end
  end

  describe '#option' do
    it 'creates an option' do
      command = Clive::Command.new
      command.option :O, :opt, 'An option', :tail => true
      
      opt = command.find('-O')
      opt.name.must_equal :opt
      opt.description.must_equal 'An option'
      opt.must_be :tail?
    end
  end

  describe '#boolean' do
    it 'creates a new boolean option' do
      command = Clive::Command.new
      command.boolean :auto, 'Auto build', :head => true
      
      bool = command.find('--auto')
      bool.name.must_equal :auto
      bool.description.must_equal 'Auto build'
      bool.must_be :head?
      bool.must_be :boolean?
    end
  end
  
  describe '#action' do
    it 'stores a block' do
      command = Clive::Command.new
      block = proc {}
      command.action &block
      command.instance_variable_get(:@block).to_s.must_equal block.to_s
    end
  end

  describe '#description' do
    it 'sets the description' do
      command = Clive::Command.new
      command.description 'Some description'
      command.instance_variable_get(:@_last_desc).must_equal 'Some description'
    end
    
    it 'gets the description' do
      command = Clive::Command.new [], 'A command'
      command.description.must_equal 'A command'
    end
  end

  describe '#find' do
    before do
      @command = Clive::Command.new [:command] do
        bool :F, :force
        opt :auto_build
      end
      @command.run_block
    end
  
    it 'finds boolean options' do
      @command.find('--force').name.must_equal :force
    end
    
    it 'finds short options' do
      @command.find('-F').name.must_equal :force
    end
    
    it 'does not find short negative boolean options' do
      @command.find('--no-F').must_be_nil
    end
    
    it 'finds negative boolean options' do
      @command.find('--no-force').name.must_equal :force
    end
    
    it 'finds options with multiple words in name' do
      @command.find('--auto_build').name.must_equal :auto_build
    end
    
    it 'finds options with dashes in name' do
      @command.find('--auto-build').name.must_equal :auto_build
    end
    
    it 'does not find non existent options' do
      @command.find('--no-auto-build').must_be_nil
      @command.find('--unreal').must_be_nil
    end
  end
  
  describe '#find_option' do
    before do
      @command = Clive::Command.new do
        bool :F, :force
        opt :auto_build
      end
      @command.run_block
    end
  
    it 'finds boolean options' do
      @command.find_option(:force).name.must_equal :force
    end
    
    it 'finds short options' do
      @command.find_option(:F).name.must_equal :force
    end
    
    it 'does not find short negative boolean options' do
      @command.find_option(:no_F).must_be_nil
    end
    
    it 'finds negative boolean options' do
      @command.find_option(:no_force).name.must_equal :force
    end
    
    it 'finds options with multiple words in name' do
      @command.find_option(:auto_build).name.must_equal :auto_build
    end
    
    it 'does not find non existent options' do
      @command.find_option(:no_auto_build).must_be_nil
      @command.find_option(:unreal).must_be_nil
    end
  end
  
  describe '#has?' do
    it 'tries to find the option' do
      command = Clive::Command.new
      command.must_receive(:find).with('--option').and_return(Clive::Option.new)
      command.has?('--option').must_be_true
    end
  end
  
  describe '#group' do
    it 'sets the group for options created' do
      command = Clive::Command.new do
        group 'Testing'
        opt :test
        group 'Changed'
        opt :change
        opt :manual, :group => 'Set'
      end
      command.run_block
      
      command.find_option(:test).opts[:group].must_equal   'Testing'
      command.find_option(:change).opts[:group].must_equal 'Changed'
      command.find_option(:manual).opts[:group].must_equal 'Set'
    end
  end
  
  describe '#end_group' do
    it 'calls #group with nil' do
      command = Clive::Command.new do
        group 'Testing'
        option :test
        end_group
        option :none
      end
      command.run_block
      
      command.find_option(:none).opts[:group].must_be_nil
    end
  end
  
  describe '#help' do
    it 'builds a help string using the defined formatter' do
      f = MiniTest::Mock.new
      f.expect :header=, nil, ['Top']
      f.expect :footer=, nil, ['Bottom']
      f.expect :options, nil, []
      f.expect :to_s, nil, []
      
      command = Clive::Command.new :formatter => f do
        header 'Top'
        footer 'Bottom'
      end
      command.help
    end
  end

end