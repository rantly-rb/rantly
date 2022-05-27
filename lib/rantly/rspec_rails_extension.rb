require 'rspec-rails'
require 'rantly/property'

class RSpec::Core::ExampleGroup
  def property_of(&block)
    Rantly::Property.new(block)
  end
end
