require 'test/unit'

module Test::Unit::Assertions
  def property_of(&block)
    Rantly::Property.new(block)
  end
end
