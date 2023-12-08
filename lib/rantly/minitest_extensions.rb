require 'minitest'
require 'rantly/property'
require "minitest/unit" unless defined?(MiniTest)

test_class = if defined?(MiniTest::Test)
               MiniTest::Test
             else
               MiniTest::Unit::TestCase
             end

test_class.class_eval do
  def property_of(&blk)
    Rantly::Property.new(blk)
  end
end
