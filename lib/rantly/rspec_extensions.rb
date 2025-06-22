# frozen_string_literal: true

require 'rspec/core'
require 'rantly/property'

class RSpec::Core::ExampleGroup
  def property_of(&block)
    Rantly::Property.new(block)
  end
end
