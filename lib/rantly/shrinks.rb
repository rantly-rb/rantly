# Integer : shrink to zero
class Integer
  def shrink(position)
    shrunk = if self > 8
      self / 2
    elsif self > 0
      self - 1
    elsif self < -8
      (self + 1) / 2
    elsif self < 0
      self + 1
    else
      0
    end
    return shrunk, -1
  end

  def shrinkable?
    self != 0
  end
end

# String : shrink to ""
class String
  def shrink(position)
    shrunk = self.dup
    if self.size > 0
      idx = Random::rand(self.size)
      shrunk[idx] = ""
    end
    return shrunk, -1
  end

  def shrinkable?
    self != ""
  end
end

# Completly unshrinkable array
class Static
  def initialize(a)
    @array = a
  end

  def [](i)
    @array[i]
  end

  def []=(i, value)
    @array[i] = value
  end

  def to_s
    @array.to_s.insert(1, "S ")
  end

  def inspect
    self.to_s
  end
end

# Array where elements can be shrunk but not removed
class Tuple
  def initialize(a)
    @array = a
  end

  def [](i)
    @array[i]
  end

  def []=(i, value)
    @array[i] = value
  end

  def to_s
    @array.to_s.insert(1, "T ")
  end

  def inspect
    self.to_s
  end

  def shrink(position)
    shrunk = @array.dup
    if position >= @array.length
      position = @array.length - 1
    end
    while position >= 0
      e = @array.at(position)
      if e.respond_to?(:shrinkable?) && e.shrinkable?
        break
      end
      position -= 1
    end
    if position >= 0
      shrunk[position], p = e.shrink(65535)
      position -= 1
    end
    return Tuple.new(shrunk), position
  end

  def shrinkable?
    @array.any? {|e| e.respond_to?(:shrinkable?) && e.shrinkable? }
  end
end

# Normal array: if elements can't be shrunk, they are removed
class Array
  def shrink(position)
    shrunk = self.dup
    if position >= self.length
      position = self.length - 1
    end
    if position >= 0
      e = self.at(position)
      if e.respond_to?(:shrinkable?) && e.shrinkable?
        shrunk[position], p = e.shrink(65535)
      else
        shrunk.delete_at(position)
      end
      position -= 1
    end
    return shrunk, position
  end

  def shrinkable?
    !self.empty?
  end
end

class Hash
  def shrink(position)
    shrunk = self.dup
    keys = shrunk.keys
    if position >= self.length
      position = self.length - 1
    end
    if position >= 0
      k = keys.at(position)
      e = self[k]
      if e.respond_to?(:shrinkable?) && e.shrinkable?
        shrunk[k], p = e.shrink(65535)
      else
        shrunk.delete(k)
      end
      position -= 1
    end
    return shrunk, position
  end

  def shrinkable?
    !self.empty?
  end
end
