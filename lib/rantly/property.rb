require 'rantly'
require 'pp'
require 'stringio'

class Rantly::Property
  attr_reader :failed_data, :shrunk_failed_data

  VERBOSITY = ENV.fetch('RANTLY_VERBOSE', 1).to_i
  RANTLY_COUNT = ENV.fetch('RANTLY_COUNT', 100).to_i

  def io
    @io ||= if VERBOSITY >= 1
              $stdout
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

  def check(n = RANTLY_COUNT, limit = 10, &assertion)
    i = 0
    test_data = nil
    begin
      Rantly.singleton.generate(n, limit, @property) do |val|
        test_data = val
        yield(val) if assertion
        io.puts '' if (i % 100).zero?
        io.print '.' if (i % 10).zero?
        i += 1
      end
      io.puts
      io.puts "SUCCESS - #{i} successful tests"
    rescue Rantly::TooManyTries => e
      io.puts
      io.puts "FAILURE - #{i} successful tests, too many tries: #{e.tries}"
      raise e.exception("#{i} successful tests, too many tries: #{e.tries} (limit: #{e.limit})")
    rescue Exception => e
      io.puts
      io.puts "FAILURE - #{i} successful tests, failed on:"
      pretty_print test_data
      @failed_data = test_data
      if @failed_data.respond_to?(:shrink)
        @shrunk_failed_data, @depth = shrinkify(assertion, @failed_data)
        io.puts "Minimal failed data (depth #{@depth}) is:"
        pretty_print @shrunk_failed_data
      end
      raise e.exception("#{i} successful tests, failed on:\n#{test_data}\n\n#{e}\n")
    end
  end

  # Explore the failures tree
  def shrinkify(assertion, data, depth = 0, iteration = 0)
    min_data = data
    max_depth = depth
    if data.shrinkable?
      while iteration < 1024
        # We assume that data.shrink is non-destructive
        shrunk_data = data.shrink
        begin
          assertion.call(shrunk_data)
        rescue Exception
          # If the assertion was verified, recursively shrink failure case
          branch_data, branch_depth, iteration = shrinkify(assertion, shrunk_data, depth + 1, iteration + 1)
          if branch_depth > max_depth
            min_data = branch_data
            max_depth = branch_depth
          end
        end
        break unless data.retry?
      end
    end
    [min_data, max_depth, iteration]
  end
end
