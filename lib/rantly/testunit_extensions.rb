require 'test/unit'
require 'rantly/property'

module Test::Unit::Assertions
  def property_of(&block)
    Rantly::Property.new(block)
  end
end
