# frozen_string_literal: true

require 'test_helper'
require 'rantly/minitest_extensions'

module RantlyTest
end

describe Rantly::Property do
  before do
    Rantly.gen.reset
  end

  it 'fail test generation' do
    print "\n### TESTING A FAILING CASE, do not get scared"
    assert_raises(Rantly::TooManyTries) do
      property_of { guard range(0, 1).negative? }.check
    end
  end

  # call

  it 'call Symbol as method call (no arg)' do
    property_of { call(:integer) }.check { |i| i.is_a?(Integer) }
  end

  it 'call Symbol as method call (with arg)' do
    property_of do
      n = range(0, 100)
      [n, call(:integer, n)]
    end.check do |(n, i)|
      assert n.abs >= i.abs
    end
  end

  it 'call Array by calling first element as method, the rest as args' do
    assert_raises(RuntimeError) do
      Rantly.gen.value do
        call []
      end
    end
    property_of do
      i = integer
      [i, call(choose([:literal, i], [:range, i, i]))]
    end.check do |(a, b)|
      assert_equal a, b
    end
  end

  it 'call Proc with generator.instance_eval' do
    property_of do
      call proc { true }
    end.check do |o|
      assert_equal true, o
    end
    property_of do
      i0 = range(0, 100)
      i1 = call proc {
        range(i0 + 1, i0 + 100)
      }
      [i0, i1]
    end.check do |(i0, i1)|
      assert i0.is_a?(Integer) && i1.is_a?(Integer)
      assert i1 > i0
      assert i1 <= (i0 + 100)
    end
  end

  it 'raise if calling on any other value' do
    assert_raises(RuntimeError) do
      Rantly.gen.call 0
    end
  end

  # branch

  it 'branch by Rantly#calling one of the args' do
    property_of do
      branch :integer, :integer, :integer
    end.check do |o|
      assert o.is_a?(Integer)
    end
    property_of do
      sized(10) { branch :integer, :string }
    end.check do |o|
      assert o.is_a?(Integer) || o.is_a?(String)
    end
  end

  # choose

  it 'choose a value from args ' do
    property_of do
      choose
    end.check do |o|
      assert_nil o
    end
    property_of do
      choose 1
    end.check do |o|
      assert_equal 1, o
    end
    property_of do
      choose 1, 2
    end.check do |o|
      assert [1, 2].include? o
    end
    property_of do
      arr = sized(10) { array { integer } }
      choose(*arr)
    end.check do |o|
      assert o.is_a?(Integer)
    end
    property_of do
      # array of array of ints
      arr = sized(10) { array { array { integer } } }
      # choose an array from an array of arrays of ints
      choose(*arr)
    end.check do |arr|
      assert arr.is_a?(Array)
      assert arr.all? { |o| o.is_a?(Integer) }
    end
  end

  # freq

  it 'not pick an element with 0 frequency' do
    property_of do
      sized(10) do
        array { freq([0, :string], [1, :integer]) }
      end
    end.check do |arr|
      assert arr.all? { |o| o.is_a?(Integer) }
    end
  end

  it 'handle degenerate freq pairs' do
    assert_raises(RuntimeError) do
      Rantly.gen.value do
        freq
      end
    end
    property_of do
      i = integer
      [i, freq([:literal, i])]
    end.check do |(a, b)|
      assert_equal a, b
    end
  end
end

# TODO: Determine type of tests required here.

# check we generate the right kind of data.
## doesn't check for distribution
class RantlyTest::Generator < Minitest::Test
  def setup
    Rantly.gen.reset
  end
end

# TODO: check that distributions of different methods look roughly correct.
class RantlyTest::Distribution < Minitest::Test
end
