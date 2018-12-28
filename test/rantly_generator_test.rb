require 'test_helper'
require 'rantly/minitest_extensions'

describe Rantly do
  before do
    Rantly.gen.reset
  end

  describe '#range' do
    it 'returns an integer within range when given two integers' do
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
        assert int.is_a?(Integer)
        assert((lo..hi).include?(int))
      }
    end

    it 'returns a float within range when given one float and one integer' do
      property_of {
        lo, hi = [integer(100),integer(100).to_f].sort
        [lo,hi,range(lo,hi)]
      }.check { |(lo,hi,float)|
        assert float.is_a?(Float)
        assert((lo..hi).include?(float))
      }
    end

    it 'returns a float within range when given two floats' do
      property_of {
        lo, hi = [integer(100).to_f,integer(100).to_f].sort
        [lo,hi,range(lo,hi)]
      }.check { |(lo,hi,float)|
        assert float.is_a?(Float)
        assert((lo..hi).include?(float))
      }
    end
  end
end
