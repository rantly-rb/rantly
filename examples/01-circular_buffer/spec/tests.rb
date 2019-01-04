require 'rantly'
require 'rantly/rspec_extensions'
require 'rantly/shrinks'

PROGRAM = './circular_buffer'.freeze
FILE = 'circular_buffer.txt'.freeze

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
      'get()'
    when :put
      "put(#{self[1]})"
    when :length
      'length()'
     end
  end

  def inspect
    to_s
  end
end

class Rantly
  def myTestData
    Tuple.new [
      Deflating.new(
        array(integer % 8 + 1) do              # series of operations with their parameters
          Operation.new [
            (choose :get, :put, :length),
            integer % 65_536                   # (parameters make sense only for :put)
          ]
        end
      ),
      integer % 10 # size of queue
    ]
  end
end

RSpec.describe 'my circular buffer' do
  it 'can do a series of operations' do
    property_of { myTestData }.check do |test|
      model = []
      size = test[1]
      `rm -f #{FILE}`
      `#{PROGRAM} init #{size} 2>/dev/null`
      if size.zero?
        expect($CHILD_STATUS).to_not be_success
      else
        expect($CHILD_STATUS).to be_success
        operations = test[0]
        operations.each do |o|
          case o.operation

          when :get
            value = `#{PROGRAM} get 2>/dev/null`
            if model.empty?
              expect($CHILD_STATUS).to_not be_success
            else
              expect($CHILD_STATUS).to be_success
              value1 = value.to_i
              value2 = model.shift
              expect(value1).to be == value2
            end

          when :put
            `#{PROGRAM} put #{o.parameter} 2>/dev/null`
            if model.count >= size
              expect($CHILD_STATUS).to_not be_success
            else
              expect($CHILD_STATUS).to be_success
              model.push(o.parameter)
            end

          when :length
            value = `#{PROGRAM} length 2>/dev/null`
            expect($CHILD_STATUS).to be_success
            value1 = value.to_i
            value2 = model.count
            expect(value1).to be == value2

          end
        end
      end
    end
  end
end
