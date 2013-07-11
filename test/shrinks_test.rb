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

