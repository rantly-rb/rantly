require 'rantly'
module Rantly::Check
  def check(n=100,&block)
    Rantly.gen.each(n,&block)
  end

  def sample(n=100,&block)
    Rantly.gen.map(n,&block)
  end
end
