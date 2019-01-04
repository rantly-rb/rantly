$LOAD_PATH.unshift(File.dirname(__FILE__)) unless
  $LOAD_PATH.include?(File.dirname(__FILE__)) || $LOAD_PATH.include?(__dir__)

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
