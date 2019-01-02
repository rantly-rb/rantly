$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

class Rantly
end

require 'rantly/generator'

def Rantly(n = 1, &block)
  if n > 1
    Rantly.map(n, &block)
  else
    Rantly.value(&block)
  end
end
