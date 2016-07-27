require "../src/hashids"

hashids = Hashids.new
pp hashids.encode([1])

hashids = Hashids.new(salt: "this is my salt")
pp hash = hashids.encode([12345]) # => NkK9

hashids = Hashids.new(salt: "this is my salt")
pp numbers = hashids.decode("NkK9") # => [12345]

hashids = Hashids.new(salt: "this is my pepper")
pp numbers = hashids.decode("NkK9") # => []

hashids = Hashids.new(salt: "this is my salt")
pp hash = hashids.encode([683, 94108, 123, 5]) # => aBMswoO2UB3Sj

hashids = Hashids.new(salt: "this is my salt")
pp numbers = hashids.decode("aBMswoO2UB3Sj") # => [683, 94108, 123, 5]

hashids = Hashids.new(salt: "this is my salt", min_length: 8)
pp hash = hashids.encode([1]) # => gB0NV05e

hashids = Hashids.new(salt: "this is my salt", min_length: 8)
pp numbers = hashids.decode("gB0NV05e") # => [1]

hashids = Hashids.new(salt: "this is my salt", alphabet: "abcdefghijkABCDEFGHIJK12345")
pp hash = hashids.encode([1, 2, 3, 4, 5]) # => dEc4iEHeF3

hashids = Hashids.new(salt: "this is my salt")
pp hash = hashids.encode([5, 5, 5, 5]) # => 1Wc8cwcE

hashids = Hashids.new(salt: "this is my salt")
pp hash = hashids.encode([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]) # => kRHnurhptKcjIDTWC3sx

hashids = Hashids.new(salt: "this is my salt")

pp hashids.encode([1]) # => NV
pp hashids.encode([2]) # => 6m
pp hashids.encode([3]) # => yD
pp hashids.encode([4]) # => 2l
pp hashids.encode([5]) # => rD

hashids = Hashids.new(salt: "this is my salt")
pp hash = hashids.encode_hex("DEADBEEF") # => kRNrpKlJ

hashids = Hashids.new(salt: "this is my salt")
pp hex_str = hashids.decode_hex("kRNrpKlJ") # => "DEADBEEF"
