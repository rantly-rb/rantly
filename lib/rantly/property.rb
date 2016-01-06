require 'rantly'
require 'pp'
require 'stringio'

class Rantly::Property
  attr_reader :failed_data, :shrunk_failed_data, :io

  VERBOSITY = ENV.fetch('RANTLY_VERBOSE'){ 1 }.to_i
  RANTLY_COUNT = ENV.fetch('RANTLY_COUNT'){ 100 }.to_i

  def io
    @io ||= if VERBOSITY >= 1
              STDOUT
            else
              StringIO.new
            end
  end

  def pretty_print(object)
    PP.pp(object, io)
  end

  def initialize(property)
    @property = property
  end

  def check(n=RANTLY_COUNT,limit=10,&assertion)
    i = 0
    test_data = nil
    begin
      Rantly.singleton.generate(n,limit,@property) do |val|
        test_data = val
        assertion.call(val) if assertion
        io.puts "" if i % 100 == 0
        io.print "." if i % 10 == 0
        i += 1
      end
      io.puts
      io.puts "success: #{i} tests"
    rescue Rantly::TooManyTries => e
      io.puts
      io.puts "too many tries: #{e.tries}"
      raise e
    rescue Exception => boom
      io.puts
      io.puts "failure: #{i} tests, on:"
      pretty_print test_data
      @failed_data = test_data
      if @failed_data.respond_to?(:shrink)
        @depth, @shrunk_failed_data = shrinkify(0, assertion, @failed_data)
        io.puts "minimal failed data (depth #{@depth}) is:"
        pretty_print @shrunk_failed_data
      end
      raise boom
    end
  end

  # Explore the failures tree
  def shrinkify(depth, assertion, data)
    io.puts "Shrinking at depth #{depth}:"
    pretty_print data

    max_depth = depth
    min_data = data
    if data.shrinkable?
      loop do
        # We assume that data.shrink is non-destructive
        shrunk_data = data.shrink
        begin
          assertion.call(shrunk_data)
        rescue Exception
          # If the assertion was verified, recursively shrink failure case
          branch_depth, branch_data = shrinkify(depth + 1, assertion, shrunk_data)
          if branch_depth > max_depth
            max_depth = branch_depth
            min_data = branch_data
          end
        end
        break if !data.retry?
      end
    end
    return max_depth, min_data
  end

  def report
    distribs = self.classifiers.sort { |a,b| b[1] <=> a[1] }
    total = distribs.inject(0) { |sum,pair| sum + pair[1]}
    distribs.each do |(classifier,count)|
      format "%10.5f%% of => %s", count, classifier
    end
  end
end
