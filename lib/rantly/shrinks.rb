class Integer
  def shrink
    if self < 0 then (self / 2).floor + 1
    elsif self <= 10 && self > 0 then self - 1
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
    elsif !self.empty?
      i = Random::rand(self.length)
      a2 = self.dup
      a2.delete_at(i)
      return a2
    else
      return self
    end
  end

  def shrinkable?
    self.any?{|e| e.respond_to?(:shrinkable?) && e.shrinkable? } ||
      !self.empty?
  end
end

class Hash
  def shrink
    if self.any?{|_,v| v.respond_to?(:shrinkable?) && v.shrinkable? }
      key,_ = self.detect{|_,v| v.respond_to?(:shrinkable?) && v.shrinkable? }
      clone = self.dup
      clone[key] = clone[key].shrink
      return clone
    elsif !self.empty?
      key = self.keys.first
      h2 = self.dup
      h2.delete(key)
      return h2
    else
      return self
    end
  end

  def shrinkable?
    self.any?{|_,v| v.respond_to?(:shrinkable?) && v.shrinkable? } ||
      !self.empty?
  end
end
