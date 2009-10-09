require 'rant'
module Rant::Check
  def check(n=100,&block)
    Rant.gen.each(n,&block)
  end

  def sample(n=100,&block)
    Rant.gen.map(n,&block)
  end
end
