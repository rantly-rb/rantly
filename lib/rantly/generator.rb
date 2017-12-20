class Rantly

  class << self
    attr_writer :default_size
    def singleton
      @singleton ||= Rantly.new
      @singleton
    end

    def default_size
      @default_size || 6
    end

    def each(n,limit=10,&block)
      gen.each(n,limit,&block)
    end

    def map(n,limit=10,&block)
      gen.map(n,limit,&block)
    end

    def value(limit=10,&block)
      gen.value(limit,&block)
    end

    def gen
      self.singleton
    end
  end

  class GuardFailure < RuntimeError
  end

  class TooManyTries < RuntimeError
    def initialize(limit,nfailed)
      @limit = limit
      @nfailed = nfailed
    end

    def tries
      @nfailed
    end

    def to_s
      "Exceed gen limit #{@limit}: #{@nfailed} failed guards"
    end
  end

  # limit attempts to 10 times of how many things we want to generate
  def each(n,limit=10,&block)
    generate(n,limit,block)
  end

  def map(n,limit=10,&block)
    acc = []
    generate(n,limit,block) do |val|
      acc << val
    end
    acc
  end

  def value(limit=10,&block)
    generate(1,limit,block) do |val|
      return val
    end
  end

  def generate(n,limit_arg,gen_block,&handler)
    limit = n * limit_arg
    nfailed = 0
    nsuccess = 0
    while nsuccess < n
      raise TooManyTries.new(limit_arg*n,nfailed) if limit < 0
      begin
        val = self.instance_eval(&gen_block)
      rescue GuardFailure
        nfailed += 1
        limit -= 1
        next
      end
      nsuccess += 1
      limit -= 1
      handler.call(val) if handler
    end
  end

  attr_accessor :classifiers

  def initialize
    reset
  end

  def reset
    @size = nil
    @classifiers = Hash.new(0)
  end

  def classify(classifier)
    @classifiers[classifier] += 1
  end

  def guard(test)
    unless test
      raise GuardFailure.new
    else
      true
    end
  end

  def size
    @size || Rantly.default_size
  end

  def sized(n,&block)
    raise "size needs to be greater than zero" if n < 0
    old_size = @size
    @size = n
    r = self.instance_eval(&block)
    @size = old_size
    return r
  end

  # wanna avoid going into Bignum when calling range with these.
  INTEGER_MAX = (2**(0.size * 8 - 2) - 1) / 2
  INTEGER_MIN = -(INTEGER_MAX)
  def integer(limit=nil)
    case limit
    when Range
      hi = limit.end
      lo = limit.begin
    when Integer
      raise "n should be greater than zero" if limit < 0
      hi, lo = limit, -limit
    else
      hi, lo = INTEGER_MAX, INTEGER_MIN
    end
    range(lo,hi)
  end

  def positive_integer
    range(0)
  end

  def float(distribution=nil, center=0)
    case distribution
    when :normal
      # Sum of 6 draws from a uniform distribution give as a draw of a normal
      # distribution centered in 3 (central limit theorem).
      [rand, rand, rand, rand, rand, rand].reduce(0, :+) - 3 + center
    else
      rand
    end
  end

  def range(lo=nil,hi=nil)
    lo ||= INTEGER_MIN
    hi ||= INTEGER_MAX
    rand(hi+1-lo) + lo
  end

  def call(gen,*args)
    case gen
    when Symbol
      return self.send(gen,*args)
    when Array
      raise "empty array" if gen.empty?
      return self.send(gen[0],*gen[1..-1])
    when Proc
      return self.instance_eval(&gen)
    else
      raise "don't know how to call type: #{gen}"
    end
  end

  def branch(*gens)
    self.call(choose(*gens))
  end

  def choose(*vals)
    vals[range(0,vals.length-1)]
  end

  def literal(value)
    value
  end

  def boolean
    range(0,1) == 0 ? true : false
  end

  def freq(*pairs)
    pairs = pairs.map do |pair|
      case pair
      when Symbol, String, Proc
        [1,pair]
      when Array
        unless pair.first.is_a?(Integer)
          [1] + pair
        else
          pair
        end
      end
    end
    total = pairs.inject(0) { |sum,p| sum + p.first }
    raise(RuntimeError, "Illegal frequency:#{pairs.inspect}") if total == 0
    pos = range(1,total)
    pairs.each do |p|
      weight, gen, *args = p
      if pos <= p[0]
        return self.call(gen,*args)
      else
        pos -= weight
      end
    end
  end

  def array(n=self.size,&block)
    n.times.map { self.instance_eval(&block) }
  end

  def dict(n=self.size,&block)
    h = {}
    each(n) do
      k,v = instance_eval(&block)
      h[k] = v if guard(!h.has_key?(k))
    end
    h
  end

  module Chars

    class << self
      ASCII = (0..127).to_a.each_with_object("") { |i, obj| obj << i }

      def of(regexp)
        ASCII.scan(regexp).to_a.map! { |char| char[0].ord }
      end
    end

    ALNUM = Chars.of(/[[:alnum:]]/)
    ALPHA = Chars.of(/[[:alpha:]]/)
    BLANK = Chars.of(/[[:blank:]]/)
    CNTRL = Chars.of(/[[:cntrl:]]/)
    DIGIT = Chars.of(/[[:digit:]]/)
    GRAPH = Chars.of(/[[:graph:]]/)
    LOWER = Chars.of(/[[:lower:]]/)
    PRINT = Chars.of(/[[:print:]]/)
    PUNCT = Chars.of(/[[:punct:]]/)
    SPACE = Chars.of(/[[:space:]]/)
    UPPER = Chars.of(/[[:upper:]]/)
    XDIGIT = Chars.of(/[[:xdigit:]]/)
    ASCII = Chars.of(/./)


    CLASSES = {
      :alnum => ALNUM,
      :alpha => ALPHA,
      :blank => BLANK,
      :cntrl => CNTRL,
      :digit => DIGIT,
      :graph => GRAPH,
      :lower => LOWER,
      :print => PRINT,
      :punct => PUNCT,
      :space => SPACE,
      :upper => UPPER,
      :xdigit => XDIGIT,
      :ascii => ASCII,
    }

  end

  def string(char_class=:print)
    chars = case char_class
            when Regexp
              Chars.of(char_class)
            when Symbol
              Chars::CLASSES[char_class]
            end
    raise "bad arg" unless chars

    char_strings = chars.map { |c| c.chr }
    str = Array.new(size)
    current_index = 0
    while current_index < size
      str[current_index] = char_strings.sample
      current_index += 1
    end
    str.join
  end
end
