require 'rantly'
require 'pp'

class Rantly::Property
  attr_reader :failed_data, :shrunk_failed_data
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
    rescue Exception => boom
      puts
      puts "failure: #{i} tests, on:"
      pp test_data
      @failed_data = test_data
      if @failed_data.respond_to?(:shrink)
        @shrunk_failed_data = shrinkify(assertion, @failed_data)
        puts "minimal failed data is:"
        pp @shrunk_failed_data
      end
      raise boom
    end
  end

  # return the first success case
  def shrinkify(assertion, data)
    # We assume that data.shrink is non-destructive
    return data if !data.shrinkable?
    val = data.shrink
    begin
      assertion.call(val)
      puts "found a reduced success:"
      pp val
      return data
    rescue Exception
      puts "found a reduced failure case:"
      pp val
      # recursively shrink failure case
      return shrinkify(assertion,val)
    end
  end

  def report
    distribs = self.classifiers.sort { |a,b| b[1] <=> a[1] }
    total = distribs.inject(0) { |sum,pair| sum + pair[1]}
    distribs.each do |(classifier,count)|
      format "%10.5f%% of => %s", count, classifier
    end
  end
end
