require 'rantly'
require 'rantly/rspec_extensions'
require 'rantly/shrinks'

PROGRAM = "./circular_buffer"
FILE = "circular_buffer.txt"

class Operation < Array
  def operation
    self[0]
  end

  def parameter
    self[1]
  end

  def to_s
    case self[0]
    when :get
      "get()"
    when :put
      "put(#{self[1]})"
    when :length
      "length()"
     end
  end

  def inspect
    self.to_s
  end
end

class Rantly
  def myTestData
    Tuple.new [
      Deflating.new(
        array(integer % 8 + 1) {              # series of operations with their parameters
          Operation.new [
            (choose :get, :put, :length),
            integer % 65536                   # (parameters make sense only for :put)
          ]
        }
      ),
      integer % 10                            # size of queue
    ]
  end
end

RSpec.describe "my circular buffer" do
  it "can do a series of operations" do
    property_of { myTestData }.check do |test|
      model = []
      size = test[1]
      `rm -f #{FILE}`
      if size == 0
        `#{PROGRAM} init #{size} 2>/dev/null`
        expect($?).to_not be_success
      else
        `#{PROGRAM} init #{size} 2>/dev/null`
        expect($?).to be_success
        operations = test[0]
        operations.each do |o|
          case o.operation

          when :get
            if (model.count == 0)
              value = `#{PROGRAM} get 2>/dev/null`
              expect($?).to_not be_success
            else
              value = `#{PROGRAM} get 2>/dev/null`
              expect($?).to be_success
              value1 = value.to_i
              value2 = model.shift()
              expect(value1).to be == value2
            end

          when :put
            if (model.count >= size)
              `#{PROGRAM} put #{o.parameter} 2>/dev/null`
              expect($?).to_not be_success
            else
              `#{PROGRAM} put #{o.parameter} 2>/dev/null`
              expect($?).to be_success
              model.push(o.parameter)
            end

          when :length
            value = `#{PROGRAM} length 2>/dev/null`
            expect($?).to be_success
            value1 = value.to_i
            value2 = model.count
            expect(value1).to be == value2

          end
        end
      end
    end
  end
end
