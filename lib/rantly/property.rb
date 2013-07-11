require 'rantly'
require 'pp'

class Rantly::Property

  def initialize(property)
    @property = property
  end

  def check(n=100,limit=10,&assertion)
    i = 0
    test_data = nil
    begin
      Rantly.singleton.generate(n,limit,@property) do |val|
        test_data = val
        assertion.call(val) if assertion
        puts "" if i % 100 == 0
        print "." if i % 10 == 0
        i += 1
      end
      puts
      puts "success: #{i} tests"
    rescue Rantly::TooManyTries => e
      puts
      puts "too many tries: #{e.tries}"
      raise e
    rescue => boom
      puts
      puts "failure: #{i} tests, on:"
      pp test_data
      if test_data.respond_to?(:shrink)
        @original_test_data = test_data
        @shrunk_data = @orginial_test_data
        shrunk = shrinkify(assertion, test_data)
        puts "shrunk to: "
        pp shrunk
      end
      raise boom
    end
  end

  def shrinkify(assertion, data)
    val = data.shrink
    begin
      if assertion
        assertion.call(val)
        shrinkify(assertion, data.shrink) if val.shrinkable?
      end
    rescue => boom
      @shrunk_data = val
      if val.shrinkable?
        shrinkify(assertion, val)
      end
    end
    @shrunk_data || @orginial_test_data
  end

  def report
    distribs = self.classifiers.sort { |a,b| b[1] <=> a[1] }
    total = distribs.inject(0) { |sum,pair| sum + pair[1]}
    distribs.each do |(classifier,count)|
      format "%10.5f%% of => %s", count, classifier
    end
  end
end
