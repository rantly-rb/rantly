[![Gem version](https://badge.fury.io/rb/rantly.svg)](https://badge.fury.io/rb/rantly)

[![Build Status](https://travis-ci.org/abargnesi/rantly.svg?branch=master)](https://travis-ci.org/abargnesi/rantly)

# Imperative Random Data Generator and Quickcheck

You can use Rantly to generate random test data, and use its Test::Unit extension for property-based testing.

Rantly is basically a recursive descent interpreter, each of its method returns a random value of some type (string, integer, float, etc.).

Its implementation has no alien mathematics inside. Completely side-effect-free-free.


# Install

```
$ gem install rantly
```

```
$ irb -rrantly
> Rantly { [integer,float] } # same as Rantly.value { integer }
=> [20991307, 0.025756845811823]
> Rantly { [integer,float]}
=> [-376856492, 0.452245765751706]
> Rantly(5) { integer } # same as Rantly.map(5) { integer }
=> [-1843396915550491870, -1683855015308353854, -2291347782549033959, -951461511269053584, 483265231542292652]
```


# Data Generation

## Getting Random Data Values

```
Rantly#map(n,limit=10,&block)
  call the generator n times, and collect values
Rantly#each(n,limit=10,&block)
  call a random block n times
Rantly#value(limit=10,&block)
  call a random block once, and get its value.
```

To collect an array of random data,

```
# we want 5 random integers
> Rantly(5) { integer }
=> [-380638946, -29645239, 344840868, 308052180, -154360970]
```

To iterate over random data,

```
> Rantly.each(5) { puts integer }
296971291
504994512
-402790444
113152364
502842783
=> nil
```

To get one value of random data,

```
> Rantly { integer }
=> 278101042
```

The optional argument `limit` is used with generator guard. By default, if you want to generate n items, the generator tries at most n * 10 times.

This almost always succeeds,

```
> Rantly(5) { i = integer; guard i > 0; i }
=> [511765059, 250554234, 305947804, 127809156, 285960387]
```

This always fails,

```
> Rantly(10) { guard integer.is_a?(Float) }
Rantly::TooManyTries: Exceed gen limit 100: 101 failed guards)
```

## Random Generating Methods

The API is similiar to QuickCheck, but not exactly the same. In particular `choose` picks a random element from an array, and `range` picks a integer from an interval.

## Simple Randomness

```
Rantly#integer(n=nil)
  random positive or negative integer. Fixnum only.
Rantly#range(lo,hi)
  random integer between lo and hi.
Rantly#float
  random float
Rantly#boolean
  true or false
Rantly#literal(value)
  No-op. returns value.
Rantly#choose(*vals)
  Pick one value from among vals.
```

## Meta Randomness

A rant generator is just a mini interpreter. It's often useful to go meta,

```
Rantly#call(gen)
  If gen is a Symbol, just do a method call with send.
  If gen is an Array, the first element of the array is the method name, the rest are args.
  If gen is a Proc, instance_eval it with the generator.
```

```
> Rantly { call(:integer) }
=> -240998958
```

```
> Rantly { call([:range,0,10]) }
=> 2
```

```
> Rantly { call(Proc.new { [integer] })}
=> [522807620]
```

The `call` method is useful to implement other abstractions (See next subsection).

```
Rantly#branch(*args)
  Pick a random arg among args, and Rantly#call it.
```

50-50 chance getting an integer or float,

```
> Rantly { branch :integer, :float }
=> 0.0489446702931332
> Rantly { branch :integer, :float }
=> 494934533
```


## Frequencies

```
Rantly#freq(*pairs)
  Takes a list of 2-tuples, the first of which is the weight, and the second a Rantly#callable value, and returns a random value picked from the pairs. Follows the distribution pattern specified by the weights.
```

Twice as likely to get a float than integer. Never gets a ranged integer.

```
> Rantly { freq [1,:integer], [2,:float], [0,:range,0,10] }
```

If the "pair" is not an array, but just a symbol, `freq` assumes that the weight is 1.

```
# 50-50 between integer and float
> Rantly { freq :integer, :float }
```

If a "pair" is an Array, but the first element is not an Integer, `freq` assumes that it's a Rantly method-call with arguments, and the weight is one.

```
# 50-50 chance generating integer limited by 10, or by 20.
> Rantly { freq [:integer,10], [:integer 20] }
```


## Sized Structure

A Rantly generator keeps track of how large a datastructure it should generate with its `size` attribute.

```
Rantly#size
 returns the current size
Rantly#sized(n,&block)
 sets the size for the duration of recursive call of block. Block is instance_eval with the generator.
```

Rantly provides two methods that depends on the size

```
Rantly#array(size=default_size,&block)
  returns a sized array consisted of elements by Rantly#calling random branches.
Rantly#string(char_class=:print)
  returns a sized random string, consisted of only chars from a char_class.
Rantly#dict(size=default_size,&block)
  returns a sized random hash. The generator block should generate tuples of keys and values (arrays that have two elements, the first one is used as key, and the second as value).
```

The avaiable char classes for strings are:

```
:alnum
:alpha
:blank
:cntrl
:digit
:graph
:lower
:print
:punct
:space
:upper
:xdigit
:ascii
```

```
# sized 10 array of integers
> Rantly { array(10) { integer }}
=> [417733046, -375385433, 0.967812380000118, 26478621, 0.888588160450082, 250944144, 305584916, -151858342, 0.308123867823313, 0.316824642414253]
```

If you set the size once, it applies to all subsequent recursive structures. Here's a sized 10 array of sized 10 strings,

```
> Rantly { sized(10) { array {string}} }
=> ["1c}C/,9I#}", "hpA/UWPJ\\j", "H'~ERtI`|]", "%OUaW\\%uQZ", "Z2QdY=G~G!", "H<o|<FARGQ", "g>ojnxGDT3", "]a:L[B>bhb", "_Kl=&{tH^<", "ly]Yfb?`6c"]
```

Or a sized 10 array of sized 5 strings,

```
> Rantly {array(10){sized(5) {string}}}
=> ["S\"jf ", "d\\F-$", "-_8pa", "IN0iF", "SxRV$", ".{kQ7", "6>;fo", "}.D8)", "P(tS'", "y0v/v"]
```

Generate a hash that has 5 elements,

```
> Rantly { dict { [string,integer] }}
{"bR\\qHn"=>247003509502595457,
 "-Mp '."=>653206579583741142,
 "gY%<SV"=>-888111605212388599,
 "+SMn:r"=>-1159506450084197716,
 "^3gYfQ"=>-2154064981943219558,
 "= :/\\,"=>433790301059833691}
```

The `dict` generator retries if a key is duplicated. If it fails to generate a unique key after too many tries, it gives up by raising an error:

```
> Rantly { dict { ["a",integer] }}
Rantly::TooManyTries: Exceed gen limit 60: 60 failed guards)
```


# Property Testing

Rantly extends Test::Unit and MiniTest::Test (5.0)/MiniTest::Unit::TestCase (< 5.0) for property testing. The extensions are in their own modules. So you need to require them explicitly:

```
require 'rantly/testunit_extensions' # for 'test/unit'
require 'rantly/minitest_extensions' # for 'minitest'
require 'rantly/rspec_extensions'    # for RSpec
```

They define:

```
Test::Unit::Assertions#property_of(&block)
  The block is used to generate random data with a generator. The method returns a Rantly::Property instance, that has the method 'check'.
```

Property assertions within Test::Unit could be done like this,

```
# checks that integer only generates fixnum.
property_of {
  integer
}.check { |i|
  assert(i.is_a?(Integer), "integer property did not return Integer type")
}
```

Property assertions within Minitest could be done like this,

```
# checks that integer only generates fixnum.
property_of {
  integer
}.check { |i|
  assert_kind_of Integer, i, "integer property did not return Integer type"
}
```

Property assertions within RSpec could be done like this,

```
# checks that integer only generates fixnum.
it "integer property only returns Integer type" do
   property_of {
     integer
   }.check { |i|
     expect(i).to be_a(Integer)
   }
end
```

The check block takes the generated data as its argument. One idiom I find useful is to include a parameter of the random data for the check argument. For example, if I want to check that Rantly#array generates the right sized array, I could say,

```
property_of {
  len = integer
  [len,array(len){integer}]
}.check { |(len,arr)|
  assert_equal len, arr.length
}
```

To control the number of property tests to generate, you have three options. In order of precedence:

1. Pass an integer argument to `check`

```
property_of {
  integer
}.check(9000) { |i|
  assert_kind_of Integer, i
}
```

2. Set the `RANTLY_COUNT` environment variable

```
RANTLY_COUNT=9000 ruby my_property_test.rb
```

3. If neither of the above are set, the default will be to run the `check` block 100 times.

If you wish to have quiet output from Rantly, set environmental variable:
```
RANTLY_VERBOSE=0 # silent
RANTLY_VERBOSE=1 # verbose and default if env is not set
```
This will silence the puts, print, and pretty_print statements in property.rb.

# Shrinking

Shrinking reduces the value of common types to some terminal lower bound. These functions are added to the Ruby types `Integer`, `String`, `Array`, and `Hash`.

For example a `String` is shrinkable until it is empty (e.g. `""`),

```
"foo".shrinkable?     # => true
"foo".shrink          # => "fo"
"fo".shrink           # => "f"
"f".shrink            # => ""
"".shrinkable?        # => false
```

Shrinking allows `Property#check` to find a reduced value that still fails the condition. The value is not truely minimal because:

* we do not perform a complete in-depth traversal of the failure tree
* we limit the search to a maximum 1024 shrinking operations

but is usually reduced enough to start debugging.

Enable shrinking with

```
require 'rantly/shrinks'
```

Use `Tuple` class if you want an array whose elements are individually shrinked, but are not removed. Example:

```
property_of {
  len = range(0, 10)
  Tuple.new( array(len) { integer } )
}.check {
  # .. property check here ..
}
```

Use `Deflating` class if you want an array whose elements are individully shrinked whenever possible, and removed otherwise. Example:

```
property_of {
  len = range(0, 10)
  Deflating.new( array(len) { integer } )
}.check {
  # .. property check here ..
}
```

Normal arrays or hashes are not shrinked.


# License

Code published under MIT License, Copyright (c) 2009 Howard Yeh. See [LICENSE](https://github.com/abargnesi/rantly/LICENSE)
