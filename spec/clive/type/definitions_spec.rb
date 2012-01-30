$: << File.dirname(__FILE__) + '/../..'
require 'helper'

describe Clive::Type::Object do
  subject { Clive::Type::Object }

  describe '#valid?' do
    it 'is always valid' do
      subject.must_be :valid?, 'a'
    end
  end

  describe '#typecast' do
    it 'returns the argument given' do
      subject.typecast('a').must_be_kind_of Object
    end
  end
end

describe Clive::Type::String do
  subject { Clive::Type::String }

  describe '#valid?' do
    it 'is valid for non nil values' do
      subject.must_be :valid?, 'a'
      subject.wont_be :valid?, nil
    end
  end

  describe '#typecast' do
    it 'returns a String' do
      subject.typecast('a').must_be_kind_of String
    end
  end
end

describe Clive::Type::Symbol do
  subject { Clive::Type::Symbol }

  describe '#valid?' do
    it 'is valid for non nil values' do
      subject.must_be :valid?, 'a'
      subject.wont_be :valid?, nil
    end
  end

  describe '#typecast' do
    it 'returns a Symbol' do
      subject.typecast('a').must_be_kind_of Symbol
    end
  end
end

describe Clive::Type::Integer do
  subject { Clive::Type::Integer }

  describe '#valid?' do
    it 'is valid for numbers' do
      %w(120 120.5 .5 120e7 120.5e7).all? {|a|
        subject.valid?(a) && subject.valid?('-'+a)
      }.must_be_true
      subject.wont_be :valid?, 'abc'
    end
  end

  describe '#typecast' do
    it 'returns an Integer' do
      r = subject.typecast('120.50e7')
      r.must_be_kind_of Integer
      r.must_equal 120
    end
  end
end

describe Clive::Type::StrictInteger do
  subject { Clive::Type::StrictInteger }

  describe '#valid?' do
    it 'is valid for integers' do
      %w(120 120e7).all? {|a|
        subject.valid?(a) &&
        subject.valid?('-'+a)
      }.must_be_true

      %w(120.5 .5 120.5e7).all? {|a|
        subject.valid?(a) &&
        subject.valid?('-'+a)
      }.must_be_false

      subject.wont_be :valid?, 'abc'
    end
  end

  describe '#typecast' do
    it 'returns an Integer' do
      r = subject.typecast('120.50e7')
      r.must_be_kind_of Integer
      r.must_equal 120
    end
  end
end

describe Clive::Type::Binary do
  subject { Clive::Type::Binary }

  describe '#valid?' do
    it 'is valid for binary numbers' do
      %w(1 11 101).all? {|a|
        subject.valid?(a) &&
        subject.valid?('-'+a) &&
        subject.valid?('0b'+a) &&
        subject.valid?('-0b'+a)
      }.must_be_true
    end
  end

  describe '#typecast' do
    it 'returns an Integer' do
      r = subject.typecast('0b101')
      r.must_be_kind_of Integer
      r.must_equal 5
    end
  end
end

describe Clive::Type::Octal do
  subject { Clive::Type::Octal }

  describe '#valid?' do
    it 'is valid for octal numbers' do
      %w(4 62 701).all? {|a|
        subject.valid?(a) &&
        subject.valid?('-'+a) &&
        subject.valid?('0'+a) &&
        subject.valid?('0o'+a) &&
        subject.valid?('-0O'+a)
      }.must_be_true
    end
  end

  describe '#typecast' do
    it 'returns an Integer' do
      r = subject.typecast('0257')
      r.must_be_kind_of Integer
      r.must_equal 175
    end
  end
end

describe Clive::Type::Hexadecimal do
  subject { Clive::Type::Hexadecimal }

  describe '#valid?' do
    it 'is valid for hexadecimal numbers' do
      %w(aa1 4f 66bb1).all? {|a|
        subject.valid?(a) &&
        subject.valid?('-'+a) &&
        subject.valid?('0x'+a) &&
        subject.valid?('-0X'+a)
      }.must_be_true
    end
  end

  describe '#typecast' do
    it 'returns an Integer' do
      r = subject.typecast('0x4f')
      r.must_be_kind_of Integer
      r.must_equal 79
    end
  end
end

describe Clive::Type::Float do
  subject { Clive::Type::Float }

  describe '#valid?' do
    it 'is valid for numbers' do
      %w(120 120.5 .5 120e7 120.5e7).all? {|a|
        subject.valid?(a) && subject.valid?('-'+a)
      }.must_be_true
      subject.wont_be :valid?, 'abc'
    end
  end

  describe '#typecast' do
    it 'returns a Float' do
      r = subject.typecast('120.50e7')
      r.must_be_kind_of Float
      r.must_equal 120.5e7
    end
  end
end

describe Clive::Type::Boolean do
  subject { Clive::Type::Boolean }

  describe '#valid?' do
    it 'is valid for various true and false values' do
      %w(true t yes y on false f no n off).all? {|a| subject.valid? a }.must_be_true
      subject.wont_be :valid?, 'abc'
    end
  end

  describe '#typecast' do
    it 'returns a Boolean' do
      subject.typecast('y').must_be_true
      subject.typecast('off').must_be_false
    end
  end
end

describe Clive::Type::Pathname do
  subject { Clive::Type::Pathname }

  describe '#valid?' do
    it 'is valid for non nil values' do
      subject.must_be :valid?, '~/path'
      subject.wont_be :valid?, nil
    end
  end

  describe '#typecast' do
    it 'returns a Pathname' do
      r = subject.typecast('~/path')
      r.must_be_kind_of Pathname
      r.to_s.must_equal '~/path'
    end
  end
end

describe Clive::Type::Range do
  subject { Clive::Type::Range }

  describe '#valid?' do
    it 'is valid for ranges' do
      %w(1..5 1...5 1-5).all? {|a| subject.valid? a }.must_be_true
    end
  end

  describe '#typecast' do
    it 'returns a Range for a...z' do
      r = subject.typecast('a...z')
      r.must_be_kind_of Range
      r.must_equal 'a'...'z'
    end

    it 'returns a Range for a..z' do
      r = subject.typecast('a..z')
      r.must_be_kind_of Range
      r.must_equal 'a'..'z'
    end

    it 'returns a Range for a-z' do
      r = subject.typecast('a-z')
      r.must_be_kind_of Range
      r.must_equal 'a'..'z'
    end
  end
end

describe Clive::Type::Array do
  subject { Clive::Type::Array }

  describe '#valid?' do
    it 'is valud for arrays' do
      ['a,b,c', '"hello",123,true,"what a sentence"'].all? {|a|
        subject.valid? a
      }.must_be_true
    end
  end

  describe '#typecast' do
    it 'returns an Array' do
      r = subject.typecast('"hello",123,true,"what a sentence"')
      r.must_be_kind_of Array
      r.must_equal ['"hello"', '123', 'true', '"what a sentence"']
    end
  end
end

describe Clive::Type::Time do
  subject { Clive::Type::Time }

  describe '#valid?' do
    it 'is valid for times' do
      %w(12:50 12:50:30).all? {|a| subject.valid?(a) }.must_be_true
    end
  end

  describe '#typecast' do
    it 'returns a Time' do
      subject.typecast('12:50').must_be_kind_of Time
    end
  end
end

describe Clive::Type::Regexp do
  subject { Clive::Type::Regexp }

  describe '#valid?' do
    it 'is valid for regular expressions' do
      %w{/a/ /a[bc](1|2)/ix}.all? {|a| subject.valid?(a) }.must_be_true
    end
  end

  describe '#typecast' do
    it 'returns a Regexp' do
      subject.typecast('/a/i').must_be_kind_of Regexp
      subject.typecast('/a/ix').must_equal /a/ix
    end
  end
end
