require 'test_helper'
require 'rantly/shrinks'
require 'rantly/minitest_extensions'

module RantlyTest
end

module RantlyTest::Shrinkers
end

describe Integer do
  it 'not be able to shrink 0 integer' do
    assert !0.shrinkable?
  end

  it 'shrink positive integers to something less than itself' do
    assert(3.shrink < 3)
    assert(2.shrink < 2)
    assert_equal(0, 1.shrink)
  end

  it 'shrink negative integers to something larger than itself' do
    assert(-3.shrink > -3)
    assert(-2.shrink > -2)
    assert_equal(0, -1.shrink)
  end

  it 'shrink 0 to itself' do
    # hmm. should this be undefined?
    assert_equal 0.shrink, 0
  end
end

describe String do
  it 'not be able to shrink empty string' do
    assert !''.shrinkable?
  end

  it 'shrink a string one char shorter' do
    property_of do
      sized(10) { string }
    end.check do |str|
      assert_equal 9, str.shrink.length
    end
  end
end

describe Tuple do
  it 'not be able to shrink empty tuple' do
    assert !Tuple.new([]).shrinkable?
  end

  it 'shrink tuple by trying to shrink the last shrinkable element available' do
    assert_equal [1, 0], Tuple.new([1, 1]).shrink.array
    assert_equal [1, 0, 0], Tuple.new([1, 1, 0]).shrink.array
  end

  it 'do not remove element from array when no element is shrinkable' do
    property_of do
      n = integer(1..10)
      a = Tuple.new(Array.new(n, 0))
      [n, a]
    end.check do |n, a|
      assert_equal n, a.shrink.length
    end
  end
end

describe Hash do
  it 'not be able to shrink empty hash' do
    assert !{}.shrinkable?
  end

  it 'shrink a value if one of the values is shrinkable' do
    assert_equal({ foo: 0, bar: 0 }, { foo: 1, bar: 0 }.shrink)
    assert_equal({ foo: 0, bar: 0 }, { foo: 0, bar: 1 }.shrink)
  end

  it 'shrink by deleting an element in it if none of the values is shrinkable' do
    assert_equal({}, { foo: 0 }.shrink)
  end
end

describe 'Shrinker Test' do
  it 'shrink data to smallest value that fails assertion' do
    print "\n### TESTING A FAILING CASE, do not get scared"
    # We try to generate an array of 10 elements, filled with ones.
    # The property we try to test is that non of the element is
    # larger than 1, and the array's length is less than 4.
    test = property_of do
      a = Deflating.new(Array.new(10, 1))
      i = Random.rand(a.length)
      a[i] = 1
      a
    end
    assert_raises Minitest::Assertion do
      test.check do |a|
        assert(a.array.none?(&:positive?) && a.length < 4, 'contains 1')
      end
    end

    assert_equal [1], test.shrunk_failed_data.array
  end
end
