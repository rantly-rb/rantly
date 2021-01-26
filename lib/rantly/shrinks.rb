# Integer : shrink to zero
class Integer
  def shrink
    if self > 8
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
    shrunk = dup
    unless empty?
      idx = Random.rand(size)
      shrunk[idx] = ''
    end
    shrunk
  end

  def retry?
    false
  end

  def shrinkable?
    self != ''
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
    length
  end

  def to_s
    @array.to_s.insert(1, 'T ')
  end

  def inspect
    to_s
  end

  def each(&block)
    @array.each(&block)
  end

  attr_reader :array

  def shrink
    shrunk = @array.dup
    while @position >= 0
      e = @array.at(@position)
      break if e.respond_to?(:shrinkable?) && e.shrinkable?

      @position -= 1
    end
    if @position >= 0
      shrunk[@position] = e.shrink
      @position -= 1
    end
    Tuple.new(shrunk)
  end

  def retry?
    @position >= 0
  end

  def shrinkable?
    @array.any? { |e| e.respond_to?(:shrinkable?) && e.shrinkable? }
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
    length
  end

  def to_s
    @array.to_s.insert(1, 'D ')
  end

  def inspect
    to_s
  end

  def each(&block)
    @array.each(&block)
  end

  attr_reader :array

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
    Deflating.new(shrunk)
  end

  def retry?
    @position >= 0
  end

  def shrinkable?
    !@array.empty?
  end
end

class Hash
  def shrink
    if any? { |_, v| v.respond_to?(:shrinkable?) && v.shrinkable? }
      key, = detect { |_, v| v.respond_to?(:shrinkable?) && v.shrinkable? }
      clone = dup
      clone[key] = clone[key].shrink
      clone
    elsif !empty?
      key = keys.first
      h2 = dup
      h2.delete(key)
      h2
    else
      self
    end
  end

  def shrinkable?
    any? { |_, v| v.respond_to?(:shrinkable?) && v.shrinkable? } ||
      !empty?
  end

  def retry?
    false
  end
end
