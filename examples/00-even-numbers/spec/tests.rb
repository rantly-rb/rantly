# frozen_string_literal: true

require 'rantly'
require 'rantly/rspec_extensions'
require 'rantly/shrinks'

RSpec.describe 'my data set' do
  it 'returns only even numbers' do
    property_of do
      Deflating.new(array(7) { integer(0..9) })
    end.check do |a|
      expect(a.array).to all(be_even)
    end
  end
end
