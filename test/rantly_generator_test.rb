require 'test_helper'
require 'rantly/minitest_extensions'

describe Rantly do
  before do
    Rantly.gen.reset
  end

  describe '#range' do
    it 'returns integer equal to start and end of range when they are the same' do
      property_of {
        num = integer
        [num, range(num, num)]
      }.check { |(num, num_in_range)|
        assert_equal num, num_in_range
      }
    end

    it 'returns an integer within range when given two integers' do
      property_of {
        lo, hi = [integer(100),integer(100)].sort
        [lo,hi,range(lo,hi)]
      }.check { |(lo,hi,num_in_range)|
        assert num_in_range.is_a?(Integer)
        assert((lo..hi).include?(num_in_range))
      }
    end

    # TODO: Replace the integer().to_f calls in the code below with calls to float() when float() supports numbers
    # larger than 1.
    it 'returns a float within range when given one float and one integer' do
      property_of {
        lo, hi = [integer(100),integer(100).to_f].sort
        [lo,hi,range(lo,hi)]
      }.check { |(lo,hi,num_in_range)|
        assert num_in_range.is_a?(Float)
        assert((lo..hi).include?(num_in_range))
      }
    end

    it 'returns a float within range when given two floats' do
      property_of {
        lo, hi = [integer(100).to_f,integer(100).to_f].sort
        [lo,hi,range(lo,hi)]
      }.check { |(lo,hi,num_in_range)|
        assert num_in_range.is_a?(Float)
        assert((lo..hi).include?(num_in_range))
      }
    end
  end

  describe "#guard" do
    it "fail test generation" do
      assert_raises(Rantly::TooManyTries) {
        property_of { guard range(0,1) < 0 }.check
      }
    end
  end

  describe "#integer" do
    it "generate literal value by returning itself" do
      property_of {
        i = integer
        [i,literal(i)]
      }.check { |(a,b)|
        assert_equal a, b
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
  end

  describe "#float" do
    it "generate Float" do
      property_of { float }.check { |f| assert f.is_a?(Float)}
    end

    it "generate Float with normal distribution" do
      property_of{
        center = integer(100)
        normal_points =  Array.new(100){ float(:normal, { center: center }) }
        [center, normal_points]
      }.check{ |center, normal_points|
        average_center = normal_points.sum / 100
        assert average_center.between?(center - 0.5, center + 0.5)
      }
    end
  end

  describe "#boolean" do
    it "generate Boolean" do
      property_of { boolean }.check { |t|
        assert t == true || t == false
      }
    end
  end

  describe "#string" do
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
  end

  describe "#array" do
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
        assert arr.all? { |o| [Fixnum, Float, String].include? o.class }
      }
    end
  end
end
