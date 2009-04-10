require 'test_helper'
require 'rant/check'

module RantTest
end

# check we generate the right kind of data.
## doesn't check for distribution
class RantTest::Generator < Test::Unit::TestCase
  def setup
    Rant.gen.reset
  end
  
  should "fail test generation" do
    assert_raises(Rant::TooManyTries) {
      property_of { guard range(0,1) < 0 }.check
    }
  end

  should "generate literal value by returning itself" do
    property_of {
      i = integer
      [i,literal(i)]
    }.check { |(a,b)|
      assert_equal a, b
    }
  end

  should "generate integer in range" do
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

  should "generate Fixnum only" do
    property_of  { integer }.check { |i| assert i.is_a?(Integer) }
  end

  should "generate integer less than abs(n)" do
    property_of {
      n = range(0,10)
      [n,integer(n)]
    }.check {|(n,i)|
      assert n.abs >= i.abs
    }
  end

  should "generate Float" do
    property_of { float }.check { |f| assert f.is_a?(Float)}
  end

  should "generate Boolean" do
    property_of { bool }.check { |t|
      assert t == true || t == false
    }
  end

  should "generate empty strings" do
    property_of {
      sized(0) { string }
    }.check { |s|
      assert s.empty?
    }
  end

  should "generate strings with the right regexp char classes" do
    char_classes = Rant::Chars::CLASSES.keys
    property_of {
      char_class = choose(*char_classes)
      len = range(0,10)
      sized(len) { [len,char_class,string(char_class)]}
    }.check { |(len,char_class,str)|
      t = true
      chars = Rant::Chars::CLASSES[char_class]
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

  should "generate strings matching regexp" do
    property_of {
      sized(10) { string(/[abcd]/) }
    }.check { |s|
      assert s =~ /[abcd]+/
    }
  end

  # call

  should "call Symbol as method call (no arg)" do
    property_of {call(:integer)}.check { |i| i.is_a?(Integer)}
  end

  should "call Symbol as method call (with arg)" do
    property_of {
      n = range(0,100)
      [n,call(:integer,n)]
    }.check { |(n,i)|
      assert n.abs >= i.abs
    }
  end

  should "call Array by calling first element as method, the rest as args" do
    assert_raise(RuntimeError) {
      Rant.gen.value {
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
  
  should "call Proc with generator.instance_eval" do
    property_of {
      call Proc.new { true }
    }.check { |o|
      assert_equal true, o
    }
    property_of {
      i0 = range(0,100)
      i1,s = call Proc.new {
        range(i0+1,i0+100)
      }
      [i0,i1]
    }.check { |(i0,i1)|
      assert i0.is_a?(Fixnum) && i1.is_a?(Fixnum)
      assert i0 != i1
      assert i1 > i0
    }
  end
  
  should "raise if calling on any other value" do
    assert_raise(RuntimeError) {
      Rant.gen.call 0
    }
  end

  # branch

  should "branch by Rant#calling one of the args" do
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
  
  should "choose a value from args " do
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
      arr = sized(10) { array(:integer) }
      choose(*arr) 
    }.check { |o|
      assert o.is_a?(Fixnum)
    }
    property_of {
      # array of array of ints
      arr = sized(10) { array(Proc.new { array(:integer)})}
      # choose an array from an array of arrays of ints
      choose(*arr)
    }.check { |arr|
      assert arr.is_a?(Array)
      assert arr.all? { |o| o.is_a?(Fixnum)}
    }
  end

  # freq

  should "not pick an element with 0 frequency" do
    property_of {
      sized(10) {
        array Proc.new { freq([0,:string],[1,:integer]) }
      }
    }.check { |arr|
      assert arr.all? { |o| o.is_a?(Integer)}
    }
  end

  should "handle degenerate freq pairs" do
    assert_raise(RuntimeError) {
      Rant.gen.value {
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

  should "generate empty array" do
    property_of {
      sized(0) { array(:integer)}
    }.check { |o|
      assert o.empty?
    }
  end
  
  should "generate the right sized nested arrays" do
    property_of {
      size1 = range(5,10)
      size2 = range(0,size1-1)
      array = sized(size1) { array(Proc.new { sized(size2) { array(:integer)}})}
      [size1,array]
    }.check { |(size1,outter_array)|
      assert_equal size1, outter_array.size
      assert outter_array.all? { |inner_array| inner_array.size < size1 }
    }
  end
  
  should "generate array with right types" do
    property_of {
      sized(10) { array :integer,:string,:float }
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

  should "raise if generating an array without size" do
    assert_raise(RuntimeError) {
      Rant.gen.value { array(:integer) }
    }
  end

end
  


# TODO: check that distributions of different methods look roughly correct.
class RantTest::Distribution
  
end
