require 'minitest'
require 'rantly/property'
require 'minitest/unit' unless defined?(Minitest)

test_class = if defined?(Minitest::Test)
               Minitest::Test
             else
               Minitest::Unit::TestCase
             end

test_class.class_eval do
  def property_of(&blk)
    Rantly::Property.new(blk)
  end
end
