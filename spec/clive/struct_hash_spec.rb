$: << File.dirname(__FILE__) + '/..'
require 'helper'

describe Clive::StructHash do

  subject { Clive::StructHash }

  describe '#[]' do
    it 'gets the value' do
      sh = subject.new(:a => 1)
      sh[:a].must_equal 1
    end
  end

  describe '#store' do
    it 'stores a key' do
      sh = subject.new
      sh.store :life, 42
      sh.life.must_equal 42
    end

    it 'stores multiple keys' do
      sh = subject.new
      sh.store %w(life answer), 42
      sh.life.must_equal 42
      sh.answer.must_equal 42
    end
  end

  describe 'named getter methods' do
    it 'gets the value' do
      sh = subject.new(:L => 42, :life => 42)
      sh.life.must_equal 42
      sh.L.must_equal 42
    end
  end

  describe 'named predicate methods' do
    it 'is true if key exists' do
      subject.new(:answer => 42).must_have :answer?
    end

    it 'is false if key does not exist' do
      subject.new(:answer => 42).wont_have :question?
    end
  end

  describe '#to_struct' do
    it 'uses the first names given to store' do
      sh = subject.new
      sub = subject.new(:life => 42)

      sh.store %w(admin a), true
      sh.store %w(name n), ['John', 'Doe']
      sh.store %w(sub other command), sub

      test = sh.to_struct('Person')
      test.admin.must_equal true
      test.wont_respond_to :a
      test.name.must_equal ['John', 'Doe']
      test.wont_respond_to :n
      test.sub.must_equal sub
      test.wont_respond_to :other
      test.wont_respond_to :command
      test.sub.class.must_equal subject
    end
  end

  describe '#to_h' do
    it 'uses the first names given to store' do
      sh = subject.new
      sub = subject.new(:life => 42)

      sh.store %w(admin a), true
      sh.store %w(name n), ['John', 'Doe']
      sh.store %w(sub other command), sub

      sh.to_h.must_equal :admin => true, :name => ['John', 'Doe'], :sub => {:life => 42}
    end
  end

end
