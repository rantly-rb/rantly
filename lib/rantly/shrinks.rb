# Integer : shrink to zero
class Integer
  def shrink
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
    return shrunk
  end

  def retry?
    false
  end

  def shrinkable?
    self != 0
  end
end

# String : shrink to ""
class String
  def shrink
    shrunk = self.dup
    if self.size > 0
      idx = Random::rand(self.size)
      shrunk[idx] = ""
    end
    return shrunk
  end

  def retry?
    false
  end

  def shrinkable?
    self != ""
  end
end

# Array where elements can be shrunk but not removed
class Tuple
  def initialize(a)
    @array = a
    @position = a.size - 1
  end

  def [](i)
    @array[i]
  end

  def []=(i, value)
    @array[i] = value
  end

  def length
    @array.length
  end

  def size
    self.length
  end

  def to_s
    @array.to_s.insert(1, "T ")
  end

  def inspect
    self.to_s
  end

  def each(&block)
    @array.each(&block)
  end

  def array
    return @array
  end

  def shrink
    shrunk = @array.dup
    while @position >= 0
      e = @array.at(@position)
      if e.respond_to?(:shrinkable?) && e.shrinkable?
        break
      end
      @position -= 1
    end
    if @position >= 0
      shrunk[@position] = e.shrink
      @position -= 1
    end
    return Tuple.new(shrunk)
  end

  def retry?
    @position >= 0
  end

  def shrinkable?
    @array.any? {|e| e.respond_to?(:shrinkable?) && e.shrinkable? }
  end
end

# Array where the elements that can't be shrunk are removed
class Deflating
  def initialize(a)
    @array = a
    @position = a.size - 1
  end

  def [](i)
    @array[i]
  end

  def []=(i, value)
    @array[i] = value
  end

  def length
    @array.length
  end

  def size
    self.length
  end

  def to_s
    @array.to_s.insert(1, "D ")
  end

  def inspect
    self.to_s
  end

  def each(&block)
    @array.each(&block)
  end

  def array
    return @array
  end

  def shrink
    shrunk = @array.dup
    if @position >= 0
      e = @array.at(@position)
      if e.respond_to?(:shrinkable?) && e.shrinkable?
        shrunk[@position] = e.shrink
      else
        shrunk.delete_at(@position)
      end
      @position -= 1
    end
    return Deflating.new(shrunk)
  end

  def retry?
    @position >= 0
  end

  def shrinkable?
    !@array.empty?
  end
end
