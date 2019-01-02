require 'test_helper'
require 'rantly/minitest_extensions'

module RantlyTest
end

describe Rantly::Property do

  before do
    Rantly.gen.reset
  end

  # call

  it "call Symbol as method call (no arg)" do
    property_of {call(:integer)}.check { |i| i.is_a?(Integer)}
  end

  it "call Symbol as method call (with arg)" do
    property_of {
      n = range(0,100)
      [n,call(:integer,n)]
    }.check { |(n,i)|
      assert n.abs >= i.abs
    }
  end

  it "call Array by calling first element as method, the rest as args" do
    assert_raises(RuntimeError) {
      Rantly.gen.value {
        call []
      }
    }
    property_of {
      i = integer
      [i,call(choose([:literal,i],[:range,i,i]))]
    }.check { |(a,b)|
      assert_equal a, b
    }
  end

  it "call Proc with generator.instance_eval" do
    property_of {
      call Proc.new { true }
    }.check { |o|
      assert_equal true, o
    }
    property_of {
      i0 = range(0,100)
      i1 = call Proc.new {
        range(i0+1,i0+100)
      }
      [i0,i1]
    }.check { |(i0,i1)|
      assert i0.is_a?(Fixnum) && i1.is_a?(Fixnum)
      assert i1 > i0
      assert i1 <= (i0 + 100)
    }
  end

  it "raise if calling on any other value" do
    assert_raises(RuntimeError) {
      Rantly.gen.call 0
    }
  end

  # branch

  it "branch by Rantly#calling one of the args" do
    property_of {
      branch :integer, :integer, :integer
    }.check { |o|
      assert o.is_a?(Fixnum)
    }
    property_of {
      sized(10) { branch :integer, :string }
    }.check { |o|
      assert o.is_a?(Fixnum) || o.is_a?(String)
    }
  end

  # choose

  it "choose a value from args " do
    property_of {
      choose
    }.check {|o|
      assert_nil o
    }
    property_of {
      choose 1
    }.check { |o|
      assert_equal 1, o
    }
    property_of {
      choose 1,2
    }.check { |o|
      assert o == 1 || o == 2
    }
    property_of {
      arr = sized(10) { array { integer } }
      choose(*arr)
    }.check { |o|
      assert o.is_a?(Fixnum)
    }
    property_of {
      # array of array of ints
      arr = sized(10) { array { array { integer }}}
      # choose an array from an array of arrays of ints
      choose(*arr)
    }.check { |arr|
      assert arr.is_a?(Array)
      assert arr.all? { |o| o.is_a?(Fixnum)}
    }
  end

  # freq

  it "not pick an element with 0 frequency" do
    property_of {
      sized(10) {
        array { freq([0,:string],[1,:integer]) }
      }
    }.check { |arr|
      assert arr.all? { |o| o.is_a?(Integer)}
    }
  end

  it "handle degenerate freq pairs" do
    assert_raises(RuntimeError) {
      Rantly.gen.value {
        freq
      }
    }
    property_of {
      i = integer
      [i,freq([:literal,i])]
    }.check { |(a,b)|
      assert_equal a, b
    }
  end

  # it "raise if generating an array without size" do
  #   assert_raises(RuntimeError) {
  #     Rantly.gen.value { array(:integer) }
  #   }
  # end

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
