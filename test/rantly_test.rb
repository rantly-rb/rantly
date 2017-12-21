require 'test_helper'
require 'rantly/minitest_extensions'

module RantlyTest
end

describe Rantly::Property do

  before do
    Rantly.gen.reset
  end

  it "fail test generation" do
    assert_raises(Rantly::TooManyTries) {
      property_of { guard range(0,1) < 0 }.check
    }
  end

  it "generate literal value by returning itself" do
    property_of {
      i = integer
      [i,literal(i)]
    }.check { |(a,b)|
      assert_equal a, b
    }
  end

  it "generate integer in range" do
    property_of {
      i = integer
      [i,range(i,i)]
    }.check { |(a,b)|
      assert_equal a, b
    }
    property_of {
      lo, hi = [integer(100),integer(100)].sort
      [lo,hi,range(lo,hi)]
    }.check { |(lo,hi,int)|
      assert((lo..hi).include?(int))
    }
  end

  it "generate Fixnum only" do
    property_of  { integer }.check { |i| assert i.is_a?(Integer) }
  end

  it "generate integer less than abs(n)" do
    property_of {
      n = range(0,10)
      [n,integer(n)]
    }.check {|(n,i)|
      assert n.abs >= i.abs
    }
  end

  it "generate Float" do
    property_of { float }.check { |f| assert f.is_a?(Float)}
  end

  it "generate Float with normal distribution" do
    property_of{
      center = integer(100)
      normal_points =  Array.new(100){ float(:normal, { center: center }) }
      [center, normal_points]
    }.check{ |center, normal_points|
      average_center = normal_points.reduce(0, :+) / 100
      assert average_center.between?(center - 0.5, center + 0.5)
    }
  end

  it "generate Boolean" do
    property_of { boolean }.check { |t|
      assert t == true || t == false
    }
  end

  it "generate empty strings" do
    property_of {
      sized(0) { string }
    }.check { |s|
      assert s.empty?
    }
  end

  it "generate strings with the right regexp char classes" do
    char_classes = Rantly::Chars::CLASSES.keys
    property_of {
      char_class = choose(*char_classes)
      len = range(0,10)
      sized(len) { [len,char_class,string(char_class)]}
    }.check { |(len,char_class,str)|
      t = true
      chars = Rantly::Chars::CLASSES[char_class]
      str.each_byte { |c|
        unless chars.include?(c)
          t = false
          break
        end
      }
      assert_equal len, str.length
      assert t
    }
  end

  it "generate strings matching regexp" do
    property_of {
      sized(10) { string(/[abcd]/) }
    }.check { |s|
      assert s =~ /[abcd]+/
    }
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

  # array

  it "generate empty array" do
    property_of {
      sized(0) { array { integer }}
    }.check { |o|
      assert o.empty?
    }
  end

  it "generate the right sized nested arrays" do
    property_of {
      size1 = range(5,10)
      size2 = range(0,size1-1)
      array = sized(size1) { array { array(size2) { integer }}}
      [size1,array]
    }.check { |(size1,outter_array)|
      assert_equal size1, outter_array.size
      assert outter_array.all? { |inner_array| inner_array.size < size1 }
    }
  end

  it "generate array with right types" do
    property_of {
      sized(10) { array { freq(:integer,:string,:float)}  }
    }.check { |arr|
      assert arr.all? { |o|
        case o
        when Fixnum, Float, String
          true
        else
          false
        end
      }
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
