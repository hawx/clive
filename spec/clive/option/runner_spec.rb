$: << File.dirname(__FILE__) + '/../..'
require 'helper'

describe Clive::Option::Runner do
  subject { Clive::Option::Runner }

  describe '#_run' do
    it 'executes the function passed within it' do
      this {
        subject._run({}, {}, proc { puts self.name })
      }.must_output "Clive::Option::Runner\n"
    end
  end

  describe '#get' do
    it 'gets a value from state' do
      this {
        subject._run({}, {:a => 1}, proc { puts get(:a) })
      }.must_output "1\n"
    end
  end

  describe '#set' do
    it 'sets a value to state' do
      state = {}
      subject._run({}, state, proc { set(:a, 1) })
      state[:a].must_equal 1
    end
  end

  describe '#update' do
    it 'updates a state value using a method' do
      state = {:name => 'John Doe'}
      subject._run({}, state, proc {
        update :name, :upcase
      })
      state[:name].must_equal "JOHN DOE"
    end

    it 'updates a state value using a method with arguments' do
      state = {:line => "A man a plan a canal"}
      subject._run({}, state, proc {
        update :line, :gsub, /[Aa]/, 'i'
      })
      state[:line].must_equal "i min i plin i cinil"
    end

    it 'updates a state value using a block' do
      state = {:list => []}
      subject._run({}, state, proc {
        update(:list) {|l| l << 1 }
      })
      state[:list].must_equal [1]
    end

    it 'raises an exception if arguments are missing' do
      this {
        subject._run({}, {}, proc { update(:a) })
      }.must_raise ArgumentError
    end
  end

  describe '#has?' do
    it 'is true if the state contains the key' do
      this {
        subject._run({}, {:key => nil}, proc { puts has?(:key) })
      }.must_output "true\n"
    end

    it 'is false if the state does not have the key' do
      this {
        subject._run({}, {}, proc { puts has?(:key) })
      }.must_output "false\n"
    end

  end

  describe '#method_missing' do
    it 'makes the arguments available by name' do
      this {
        subject._run({:a => 1}, {}, proc { puts a })
      }.must_output "1\n"
    end

    it 'passes unknown calls to super' do
      this {
        subject.run({}, {}, proc { puts z })
      }.must_raise NoMethodError
    end
  end

end
