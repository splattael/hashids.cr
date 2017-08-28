# Hashids

[![Build Status](https://travis-ci.org/splattael/hashids.cr.svg)](https://travis-ci.org/splattael/hashids.cr)
[![Shard version](https://img.shields.io/badge/hashids.cr-v0.2.1-orange.svg)](http://crystalshards.xyz/?filter=hashids)

A small Crystal shard to generate YouTube-like ids from one or many numbers. Use hashids when you do not want to expose your database ids to the user.

http://hashids.org/crystal/

## What is it?

hashids (Hash IDs) creates short, unique, decodable hashes from unsigned integers.

See http://hashids.org for more information.

The is a port of [Ruby's implementation](https://github.com/peterhellberg/hashids.rb).
The tests were adopted from the original [JavaScript implementation](https://github.com/ivanakimov/hashids.js).

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  hashids:
    github: splattael/hashids.cr
    version: 0.2.1
```

## Usage

```crystal
require "hashids"

hashids = Hashids.new
hashids.encode([1]) # => "jR"
```

### Encoding one number

You can pass a unique salt value so your hashes differ from everyone else's.
I use **this is my salt** as an example.

```crystal
hashids = Hashids.new(salt: "this is my salt")
hash = hashids.encode([12345]) # => NkK9
```

### Decoding

Notice during decoding, same salt value is used:

```crystal
hashids = Hashids.new(salt: "this is my salt")
numbers = hashids.decode("NkK9") # => [12345]
```

### Decoding with different salt

Decoding will not work if salt is changed:

```crystal
hashids = Hashids.new(salt: "this is my pepper")
numbers = hashids.decode("NkK9") # => []
```

### Encoding several numbers

```crystal
hashids = Hashids.new(salt: "this is my salt")
hash = hashids.encode([683, 94108, 123, 5]) # => aBMswoO2UB3Sj
```

### Decoding is done the same way

```crystal
hashids = Hashids.new(salt: "this is my salt")
numbers = hashids.decode("aBMswoO2UB3Sj") # => [683, 94108, 123, 5]
```

### Encoding and specifying minimum hash length

Here we encode integer 1, and set the minimum hash length to **8**
(by default it's **0** -- meaning hashes will be the shortest possible length).

```crystal
hashids = Hashids.new(salt: "this is my salt", min_length: 8)
hash = hashids.encode([1]) # => gB0NV05e
```

### Decoding with minimum hash length

```crystal
hashids = Hashids.new(salt: "this is my salt", min_length: 8)
numbers = hashids.decode("gB0NV05e") # => [1]
```

### Specifying custom hash alphabet

Here we set the alphabet to consist of: "abcdefghijkABCDEFGHIJK12345"

```crystal
hashids = Hashids.new(salt: "this is my salt", alphabet: "abcdefghijkABCDEFGHIJK12345")
hash = hashids.encode([1, 2, 3, 4, 5]) # => dEc4iEHeF3
```

## Randomness

The primary purpose of hashids is to obfuscate ids. It's not meant or tested to be used for security purposes or compression.
Having said that, this algorithm does try to make these hashes unguessable and unpredictable:

### Repeating numbers

You don't see any repeating patterns that might show there's 4 identical numbers in the hash:

```crystal
hashids = Hashids.new(salt: "this is my salt")
hash = hashids.encode([5, 5, 5, 5]) # => 1Wc8cwcE
```

Same with incremented numbers:

```crystal
hashids = Hashids.new(salt: "this is my salt")
hash = hashids.encode([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]) # => kRHnurhptKcjIDTWC3sx
```

### Incrementing number ids:

```crystal
hashids = Hashids.new(salt: "this is my salt")

hashids.encode([1]) #=> NV
hashids.encode([2]) #=> 6m
hashids.encode([3]) #=> yD
hashids.encode([4]) #=> 2l
hashids.encode([5]) #=> rD
```

### Encoding using a HEX string

```crystal
hashids = Hashids.new(salt: "this is my salt")
hash = hashids.encode_hex("DEADBEEF") # => kRNrpKlJ
```

### Decoding to a HEX string

```crystal
hashids = Hashids.new(salt: "this is my salt")
hex_str = hashids.decode_hex("kRNrpKlJ") # => "deadbeef"
```

## Development

```shell
make spec
```

## Contributing

1. Fork it ( https://github.com/splattael/hashids/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Release

* Make sure `make spec` is green
* Commit all changes
* Bump version in `src/hashids/version.cr`
* Adjust version in `README.md` and `shard.yml`
* `make release`

## Contributors

- [splattael](https://github.com/splattael) Peter Leitzen - creator, maintainer
