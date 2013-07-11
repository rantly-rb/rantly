class Integer
  def shrink
    if self < 0 then (self / 2).floor + 1
    elsif self > 0 then ((self + 1) / 2).ceil - 1
    else
      return 0
    end
  end

  def shrinkable?
    self != 0
  end
end

class String
  def shrink
    if self.size > 0
      idx = Random::rand(self.size)
      shrunk = self.dup
      shrunk[idx] = ""
      return shrunk
    else
      return ""
    end
  end

  def shrinkable?
    self != ""
  end
end

class Array
  def shrink
    idx = find_index{|e| e.respond_to?(:shrinkable?) && e.shrinkable?}
    if idx != nil
      clone = self.dup
      clone[idx] = clone[idx].shrink
      return clone
    else
      return self
    end
  end

  def shrinkable?
    self.any?{|e| e.respond_to?(:shrinkable?) && e.shrinkable? }
  end
end

class Hash

  def shrink
    if shrinkable?
      key,_ = self.detect{|_,v| v.respond_to?(:shrinkable?) && v.shrinkable? }
      clone = self.dup
      clone[key] = clone[key].shrink
      return clone
    else
      return self
    end
  end


  def shrinkable?
    self.any?{|_,v| v.respond_to?(:shrinkable?) && v.shrinkable? }
  end
end
