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

    def each(n, limit = 10, &block)
      gen.each(n, limit, &block)
    end

    def map(n, limit = 10, &block)
      gen.map(n, limit, &block)
    end

    def value(limit = 10, &block)
      gen.value(limit, &block)
    end

    def gen
      singleton
    end
  end

  class GuardFailure < RuntimeError
  end

  class TooManyTries < RuntimeError
    def initialize(limit, nfailed)
      @limit = limit
      @nfailed = nfailed
    end

    def tries
      @nfailed
    end

    attr_reader :limit
  end

  # limit attempts to 10 times of how many things we want to generate
  def each(n, limit = 10, &block)
    generate(n, limit, block)
  end

  def map(n, limit = 10, &block)
    acc = []
    generate(n, limit, block) do |val|
      acc << val
    end
    acc
  end

  def value(limit = 10, &block)
    generate(1, limit, block) do |val|
      return val
    end
  end

  def generate(n, limit_arg, gen_block, &handler)
    limit = n * limit_arg
    nfailed = 0
    nsuccess = 0
    while nsuccess < n
      raise TooManyTries.new(limit_arg * n, nfailed) if limit.zero?

      begin
        val = instance_eval(&gen_block)
      rescue GuardFailure
        nfailed += 1
        limit -= 1
        next
      end
      nsuccess += 1
      limit -= 1
      yield(val) if handler
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
    return true if test

    raise GuardFailure
  end

  def size
    @size || Rantly.default_size
  end

  def sized(n, &block)
    raise 'size needs to be greater than zero' if n.negative?

    old_size = @size
    @size = n
    r = instance_eval(&block)
    @size = old_size
    r
  end

  # wanna avoid going into Bignum when calling range with these.
  INTEGER_MAX = (2**(0.size * 8 - 2) - 1) / 2
  INTEGER_MIN = -INTEGER_MAX
  def integer(limit = nil)
    case limit
    when Range
      hi = limit.end
      lo = limit.begin
    when Integer
      raise 'n should be greater than zero' if limit.negative?

      hi = limit
      lo = -limit
    else
      hi = INTEGER_MAX
      lo = INTEGER_MIN
    end
    range(lo, hi)
  end

  def positive_integer
    range(0)
  end

  def float(distribution = nil, params = {})
    case distribution
    when :normal
      params[:center] ||= 0
      params[:scale] ||= 1
      raise 'The distribution scale should be greater than zero' if params[:scale].negative?

      # Sum of 6 draws from a uniform distribution give as a draw of a normal
      # distribution centered in 3 (central limit theorem).
      ([rand, rand, rand, rand, rand, rand].sum - 3) * params[:scale] + params[:center]
    else
      rand
    end
  end

  def range(lo = INTEGER_MIN, hi = INTEGER_MAX)
    rand(lo..hi)
  end

  def call(gen, *args)
    case gen
    when Symbol
      send(gen, *args)
    when Array
      raise 'empty array' if gen.empty?

      send(gen[0], *gen[1..-1])
    when Proc
      instance_eval(&gen)
    else
      raise "don't know how to call type: #{gen}"
    end
  end

  def branch(*gens)
    call(choose(*gens))
  end

  def choose(*vals)
    vals[range(0, vals.length - 1)] if vals.length.positive?
  end

  def literal(value)
    value
  end

  def boolean
    range(0, 1).zero?
  end

  def freq(*pairs)
    pairs = pairs.map do |pair|
      case pair
      when Symbol, String, Proc
        [1, pair]
      when Array
        if pair.first.is_a?(Integer)
          pair
        else
          [1] + pair
        end
      end
    end
    total = pairs.inject(0) { |sum, p| sum + p.first }
    raise("Illegal frequency:#{pairs.inspect}") if total.zero?

    pos = range(1, total)
    pairs.each do |p|
      weight, gen, *args = p
      return call(gen, *args) if pos <= p[0]

      pos -= weight
    end
  end

  def array(n = size, &block)
    n.times.map { instance_eval(&block) }
  end

  def dict(n = size, &block)
    h = {}
    each(n) do
      k, v = instance_eval(&block)
      h[k] = v if guard(!h.key?(k))
    end
    h
  end

  module Chars
    class << self
      ASCII = (0..127).to_a.each_with_object('') { |i, obj| obj << i }

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
      alnum: ALNUM,
      alpha: ALPHA,
      blank: BLANK,
      cntrl: CNTRL,
      digit: DIGIT,
      graph: GRAPH,
      lower: LOWER,
      print: PRINT,
      punct: PUNCT,
      space: SPACE,
      upper: UPPER,
      xdigit: XDIGIT,
      ascii: ASCII
    }.freeze
  end

  def string(char_class = :print)
    chars = case char_class
            when Regexp
              Chars.of(char_class)
            when Symbol
              Chars::CLASSES[char_class]
            end
    raise 'bad arg' unless chars

    char_strings = chars.map(&:chr)
    str = Array.new(size)
    size.times { |i| str[i] = char_strings.sample }
    str.join
  end
end
