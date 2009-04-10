class Rant

  class << self
    def singleton
      @singleton ||= Rant.new
      @singleton
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
      "Exceed gen limit(#{@limit}: #{@nfailed} failed guards)"
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

  def value(limit=MAX_TRIES,&block)
    generate(1,limit,block) do |val|
      return val
    end
  end

  def generate(n,limit,gen_block,&handler)
    limit = n * 10
    nfailed = 0
    nsuccess = 0
    while nsuccess < n
      raise TooManyTries.new(limit,nfailed) if limit < 0
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
    raise GuardFailure.new unless test
  end

  def size
    raise "size not set" unless @size
    @size
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
  INTEGER_MAX = (2**(0.size * 8 -2) -1) / 2
  INTEGER_MIN = -(INTEGER_MAX)
  def integer(n=nil)
    if n
      raise "n should be greater than zero" if n < 0
      hi, lo = n, -n
    else
      hi, lo = INTEGER_MAX, INTEGER_MIN
    end
    range(lo,hi)
  end

  def float
    rand
  end

  def range(lo,hi)
    rand(hi+1-lo) + lo
  end

  def eval(gen,*args)
    case gen
    when Symbol
      return self.send(gen,*args)
    when Range
      return self.range(gen.begin,gen.end)
    when Array
      return gen[range(0,gen.length-1)]
    when Proc
      return self.instance_eval(&gen)
    else
      # return literal value as is
      return gen
    end
  end
  
  def choose(*from)
    args = from[range(0,from.length-1)]
    args = [args] unless args.is_a?(Array)
    self.eval(*args)
  end

  def bool
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
    raise(RuntimeError, "Illegal frequency:#{xs.inspect}") if total == 0
    pos = range(1,total)
    pairs.each do |p|
      weight, gen, *args = p
      if pos <= p[0]
        return self.eval(gen,*args)
      else
        pos -= weight
      end
    end
  end

  def array(*freq_pairs)
    acc = []
    self.size.times { acc << freq(*freq_pairs) }
    acc
  end

  module Chars
    
    class << self
      ASCII = ""
      (0..127).to_a.each do |i|
        ASCII << i
      end

      def of(regexp)
        ASCII.scan(regexp).to_a.map! { |char| char[0] }
      end
    end
    
    ALNUM = Chars.of /[[:alnum:]]/
    ALPHA = Chars.of /[[:alpha:]]/
    BLANK = Chars.of /[[:blank:]]/
    CNTRL = Chars.of /[[:cntrl:]]/
    DIGIT = Chars.of /[[:digit:]]/
    GRAPH = Chars.of /[[:graph:]]/
    LOWER = Chars.of /[[:lower:]]/
    PRINT = Chars.of /[[:print:]]/
    PUNCT = Chars.of /[[:punct:]]/
    SPACE = Chars.of /[[:space:]]/
    UPPER = Chars.of /[[:upper:]]/
    XDIGIT = Chars.of /[[:xdigit:]]/
    ASCII = Chars.of /./
    
    
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
    str = ""
    size.times do
      str << choose(*chars)
    end
    str
  end
end


