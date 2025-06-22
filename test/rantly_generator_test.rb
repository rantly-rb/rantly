# frozen_string_literal: true

require 'test_helper'
require 'rantly/minitest_extensions'

describe Rantly do
  before do
    Rantly.gen.reset
  end

  describe '#range' do
    it 'returns integer equal to start and end of range when they are the same' do
      property_of do
        num = integer
        [num, range(num, num)]
      end.check do |(num, num_in_range)|
        assert_equal num, num_in_range
      end
    end

    it 'returns an integer within range when given two integers' do
      property_of do
        lo, hi = [integer(100), integer(100)].sort
        [lo, hi, range(lo, hi)]
      end.check do |(lo, hi, num_in_range)|
        assert num_in_range.is_a?(Integer)
        assert((lo..hi).cover?(num_in_range))
      end
    end

    # TODO: Replace the integer().to_f calls in the code below with calls to float() when float() supports numbers
    # larger than 1.
    it 'returns a float within range when given one float and one integer' do
      property_of do
        lo, hi = [integer(100), integer(100).to_f].sort
        [lo, hi, range(lo, hi)]
      end.check do |(lo, hi, num_in_range)|
        assert num_in_range.is_a?(Float)
        assert((lo..hi).cover?(num_in_range))
      end
    end

    it 'returns a float within range when given two floats' do
      property_of do
        lo, hi = [integer(100).to_f, integer(100).to_f].sort
        [lo, hi, range(lo, hi)]
      end.check do |(lo, hi, num_in_range)|
        assert num_in_range.is_a?(Float)
        assert((lo..hi).cover?(num_in_range))
      end
    end
  end

  describe '#guard' do
    it 'fail test generation' do
      assert_raises(Rantly::TooManyTries) do
        # rubocop:disable Style/NumericPredicate
        property_of { guard range(0, 1) < 0 }.check
        # rubocop:enable Style/NumericPredicate
      end
    end
  end

  describe '#integer' do
    it 'generate literal value by returning itself' do
      property_of do
        i = integer
        [i, literal(i)]
      end.check do |(a, b)|
        assert_equal a, b
      end
    end

    it 'generate Integer only' do
      property_of { integer }.check { |i| assert i.is_a?(Integer) }
    end

    it 'generate integer less than abs(n)' do
      property_of do
        n = range(0, 10)
        [n, integer(n)]
      end.check do |(n, i)|
        assert n.abs >= i.abs
      end
    end
  end

  describe '#float' do
    it 'generate Float' do
      property_of { float }.check { |f| assert f.is_a?(Float) }
    end

    it 'generate Float with normal distribution' do
      property_of do
        center = integer(100)
        normal_points = Array.new(100) { float(:normal, center: center) }
        [center, normal_points]
      end.check do |center, normal_points|
        average_center = normal_points.sum / 100
        assert average_center.between?(center - 0.5, center + 0.5)
      end
    end
  end

  describe '#boolean' do
    it 'generate Boolean' do
      property_of { boolean }.check do |t|
        assert [true, false].include?(t)
      end
    end
  end

  describe '#string' do
    it 'generate empty strings' do
      property_of do
        sized(0) { string }
      end.check do |s|
        assert s.empty?
      end
    end

    it 'generate strings with the right regexp char classes' do
      char_classes = Rantly::Chars::CLASSES.keys
      property_of do
        char_class = choose(*char_classes)
        len = range(0, 10)
        sized(len) { [len, char_class, string(char_class)] }
      end.check do |(len, char_class, str)|
        t = true
        chars = Rantly::Chars::CLASSES[char_class]
        str.each_byte do |c|
          unless chars.include?(c)
            t = false
            break
          end
        end
        assert_equal len, str.length
        assert t
      end
    end

    it 'generate strings matching regexp' do
      property_of do
        sized(10) { string(/[abcd]/) }
      end.check do |s|
        assert s =~ /[abcd]+/
      end
    end
  end

  describe '#array' do
    it 'generate empty array' do
      property_of do
        sized(0) { array { integer } }
      end.check do |o|
        assert o.empty?
      end
    end

    it 'generate the right sized nested arrays' do
      property_of do
        size1 = range(5, 10)
        size2 = range(0, size1 - 1)
        array = sized(size1) { array { array(size2) { integer } } }
        [size1, array]
      end.check do |(size1, outer_array)|
        assert_equal size1, outer_array.size
        assert(outer_array.all? { |inner_array| inner_array.size < size1 })
      end
    end

    it 'generate array with right types' do
      property_of do
        sized(10) { array { freq(:integer, :string, :float) } }
      end.check do |arr|
        assert(arr.all? { |o| [Integer, Float, String].include? o.class })
      end
    end
  end
end
