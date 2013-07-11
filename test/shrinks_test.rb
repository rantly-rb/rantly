require 'test_helper'
require 'rantly/shrinks'
require 'rantly/testunit_extensions'

module RantlyTest
end

module RantlyTest::Shrinkers
end

class RantlyTest::Shrinkers::Integer < Test::Unit::TestCase
  should "not be able to shrink 0 integer" do
    assert !0.shrinkable?
  end

  should "shrink positive integers to something less than itself" do
    assert(3.shrink < 3)
    assert(2.shrink < 2)
    assert_equal(0,1.shrink)
  end

  should "shrink negative integers to something larger than itself" do
    assert(-3.shrink > -3)
    assert(-2.shrink > -2)
    assert_equal(0,-1.shrink)
  end

  should "shrink 0 to itself" do
    # hmm. should this be undefined?
    assert_equal 0.shrink, 0
  end
end

class RantlyTest::Shrinkers::String< Test::Unit::TestCase
  should "not be able to shrink empty string" do
    assert !"".shrinkable?
  end

  should "shrink a string one char shorter" do
    property_of {
      sized(10) { string }
    }.check { |str|
      assert_equal 9, str.shrink.length
    }
  end
end

class RantlyTest::Shrinkers::Array < Test::Unit::TestCase
  should "not be able to shrink empty array" do
    assert ![].shrinkable?
  end

  should "shrink array by trying to shrink the first shrinkable element available" do
    assert_equal [0,1], [1,1].shrink
    assert_equal [0,0,1], [0,1,1].shrink
  end

  should "shrink array by 1 if none of the element in it is shrinkable" do
    property_of {
      n = integer(1..10)
      a = Array.new(n,0)
      [n,a]
    }.check { |n,a|
      assert_equal n-1, a.shrink.length
    }
  end
end

class RantlyTest::Shrinkers::Hash< Test::Unit::TestCase
  should "not be able to shrink empty hash" do
    assert !{}.shrinkable?
  end

  should "shrink a value if one of the values is shrinkable" do
    assert_equal({foo: 0, bar: 0}, {foo: 1, bar: 0}.shrink)
    assert_equal({foo: 0, bar: 0}, {foo: 0, bar: 1}.shrink)
  end

  should "shrink by deleting an element in it if none of the values is shrinkable" do
    assert_equal({},{foo: 0}.shrink)
  end
end
