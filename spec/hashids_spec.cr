require "./spec_helper"

describe Hashids do
  describe "default params" do
    {
      "gY"                                       => [0],
      "jR"                                       => [1],
      "R8ZN0"                                    => [928728],
      "o2fXhV"                                   => [1, 2, 3],
      "jRfMcP"                                   => [1, 0, 0],
      "jQcMcW"                                   => [0, 0, 1],
      "gYcxcr"                                   => [0, 0, 0],
      "gLpmopgO6"                                => [1000000000000],
      "lEW77X7g527"                              => [9007199254740991],
      "BrtltWt2tyt1tvt7tJt2t1tD"                 => [5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5],
      "G6XOnGQgIpcVcXcqZ4B8Q8B9y"                => [10000000000, 0, 0, 0, 999999999999999],
      "5KoLLVL49RLhYkppOplM6piwWNNANny8N"        => [9007199254740991, 9007199254740991, 9007199254740991],
      "BPg3Qx5f8VrvQkS16wpmwIgj9Q4Jsr93gqx"      => [1000000001, 1000000002, 1000000003, 1000000004, 1000000005],
      "1wfphpilsMtNumCRFRHXIDSqT2UPcWf1hZi3s7tN" => [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20],
    }.each do |id, numbers|
      it "encodes #{numbers.inspect} to #{id.inspect}" do
        Hashids.new.encode(numbers).should eq(id)
      end

      it "decodes #{id.inspect} to #{numbers.inspect}" do
        Hashids.new.decode(id).should eq(numbers)
      end
    end
  end

  describe "encode_hex/decode_hex with default params" do
    {
      "wpVL4j9g"                                      => "deadbeef",
      "kmP69lB3xv"                                    => "abcdef123456",
      "47JWg0kv4VU0G2KBO2"                            => "ABCDDD6666DDEEEEEEEEE",
      "y42LW46J9luq3Xq9XMly"                          => "507f1f77bcf86cd799439011",
      "m1rO8xBQNquXmLvmO65BUO9KQmj"                   => "f00000fddddddeeeee4444444ababab",
      "wBlnMA23NLIQDgw7XxErc2mlNyAjpw"                => "abcdef123456abcdef123456abcdef123456",
      "VwLAoD9BqlT7xn4ZnBXJFmGZ51ZqrBhqrymEyvYLIP199" => "f000000000000000000000000000000000000000000000000000f",
      "nBrz1rYyV0C0XKNXxB54fWN0yNvVjlip7127Jo3ri0Pqw" => "fffffffffffffffffffffffffffffffffffffffffffffffffffff",
    }.each do |id, hex|
      it "encodes 0x#{hex} to #{id.inspect}" do
        Hashids.new.encode_hex(hex).should eq(id)
      end

      it "decodes #{id.inspect} to 0x#{hex}" do
        Hashids.new.decode_hex(id).should eq(hex.downcase)
      end
    end
  end

  describe "custom salt" do
    it "works empty salt" do
      test_hashids_roundtrip(salt: "")
    end

    it "works with whitespace salt" do
      test_hashids_roundtrip(salt: "    ")
    end

    it "works with normal salt" do
      test_hashids_roundtrip(salt: "this is my salt")
    end

    it "works with really long salt" do
      test_hashids_roundtrip(salt: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890`~!@#$%^&*()-_=+\\|\'\";:/?.>,<{[}]")
    end

    it "works with weird salt" do
      test_hashids_roundtrip(salt: "`~!@#$%^&*()-_=+\\|\'\";:/?.>,<{[}]")
    end
  end

  describe "custom min_hash_size" do
    it "works with 0" do
      id = test_hashids_roundtrip(min_hash_size: 0)
      id.size.should be >= 0
    end

    it "works with 1" do
      id = test_hashids_roundtrip(min_hash_size: 1)
      id.size.should be >= 1
    end

    it "works with 10" do
      id = test_hashids_roundtrip(min_hash_size: 10)
      id.size.should be >= 10
    end

    it "works with 999" do
      id = test_hashids_roundtrip(min_hash_size: 999)
      id.size.should be >= 999
    end

    it "works with 1000" do
      id = test_hashids_roundtrip(min_hash_size: 1000)
      id.size.should be >= 1000
    end
  end

  describe "custom alphabet" do
    it "works with the worst alphabet" do
      test_hashids_roundtrip(alphabet: "cCsSfFhHuUiItT01")
    end

    it "works with half the alphabet being separators" do
      test_hashids_roundtrip(alphabet: "abdegjklCFHISTUc")
    end

    it "works with exactly 2 separators" do
      test_hashids_roundtrip(alphabet: "abdegjklmnopqrSF")
    end

    it "works with no separators" do
      test_hashids_roundtrip(alphabet: "abdegjklmnopqrvwxyzABDEGJKLMNOPQRVWXYZ1234567890")
    end

    it "works with super long alphabet" do
      test_hashids_roundtrip(alphabet: %q{abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890`~!@#$%^&*()-_=+\\|\'";:/?.>,<{[}]})
    end

    it "works with a weird alphabet" do
      test_hashids_roundtrip(alphabet: %q{`~!@#$%^&*()-_=+\\|\'";:/?.>,<{[}]})
    end
  end

  describe "encode/decode with custom params" do
    {
      "nej1m3d5a6yn875e7gr9kbwpqol02q"           => [0],
      "dw1nqdp92yrajvl9v6k3gl5mb0o8ea"           => [1],
      "onqr0bk58p642wldq14djmw21ygl39"           => [928728],
      "18apy3wlqkjvd5h1id7mn5ore2d06b"           => [1, 2, 3],
      "o60edky1ng3vl9hbfavwr5pa2q8mb9"           => [1, 0, 0],
      "o60edky1ng3vlqfbfp4wr5pa2q8mb9"           => [0, 0, 1],
      "qek2a08gpl575efrfd7yomj9dwbr63"           => [0, 0, 0],
      "m3d5a6yn875rae8y81a94gr9kbwpqo"           => [1000000000000],
      "1q3y98ln48w96kpo0wgk314w5mak2d"           => [9007199254740991],
      "op7qrcdc3cgc2c0cbcrcoc5clce4d6"           => [5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5],
      "5430bd2jo0lxyfkfjfyojej5adqdy4"           => [10000000000, 0, 0, 0, 999999999999999],
      "aa5kow86ano1pt3e1aqm239awkt9pk380w9l3q6"  => [9007199254740991, 9007199254740991, 9007199254740991],
      "mmmykr5nuaabgwnohmml6dakt00jmo3ainnpy2mk" => [1000000001, 1000000002, 1000000003, 1000000004, 1000000005],
      "w1hwinuwt1cbs6xwzafmhdinuotpcosrxaz0fahl" => [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20],
    }.each do |id, numbers|
      it "encodes #{numbers.inspect} to #{id.inspect}" do
        hashids = Hashids.new(salt: "this is my salt",
          min_hash_size: 30,
          alphabet: "xzal86grmb4jhysfoqp3we7291kuct5iv0nd")
        hashids.encode(numbers).should eq(id)
      end

      it "decodes #{id.inspect} to #{numbers.inspect}" do
        hashids = Hashids.new(salt: "this is my salt",
          min_hash_size: 30,
          alphabet: "xzal86grmb4jhysfoqp3we7291kuct5iv0nd")
        hashids.decode(id).should eq(numbers)
      end
    end
  end

  describe "encode_hex/decode_hex with custom params" do
    {
      "0dbq3jwa8p4b3gk6gb8bv21goerm96"                         => "deadbeef",
      "190obdnk4j02pajjdande7aqj628mr"                         => "abcdef123456",
      "a1nvl5d9m3yo8pj1fqag8p9pqw4dyl"                         => "ABCDDD6666DDEEEEEEEEE",
      "1nvlml93k3066oas3l9lr1wn1k67dy"                         => "507f1f77bcf86cd799439011",
      "mgyband33ye3c6jj16yq1jayh6krqjbo"                       => "f00000fddddddeeeee4444444ababab",
      "9mnwgllqg1q2tdo63yya35a9ukgl6bbn6qn8"                   => "abcdef123456abcdef123456abcdef123456",
      "edjrkn9m6o69s0ewnq5lqanqsmk6loayorlohwd963r53e63xmml29" => "f000000000000000000000000000000000000000000000000000f",
      "grekpy53r2pjxwyjkl9aw0k3t5la1b8d5r1ex9bgeqmy93eata0eq0" => "fffffffffffffffffffffffffffffffffffffffffffffffffffff",
    }.each do |id, hex|
      it "encodes 0x#{hex} to #{id.inspect}" do
        hashids = Hashids.new(salt: "this is my salt",
          min_hash_size: 30,
          alphabet: "xzal86grmb4jhysfoqp3we7291kuct5iv0nd")
        hashids.encode_hex(hex).should eq(id)
      end

      it "decodes #{id.inspect} to 0x#{hex}" do
        hashids = Hashids.new(salt: "this is my salt",
          min_hash_size: 30,
          alphabet: "xzal86grmb4jhysfoqp3we7291kuct5iv0nd")
        hashids.decode_hex(id).should eq(hex.downcase)
      end
    end
  end

  describe "bad input" do
    it "raises an error when small alphabet" do
      expect_raises Exception, /at least 16 unique characters/ do
        Hashids.new(alphabet: "1234567890")
      end
    end

    it "raises an error when alphabet has spaces" do
      expect_raises Exception, /include spaces/ do
        Hashids.new(alphabet: "a cdefghijklmnopqrstuvwxyz")
      end
    end

    it "raises an error when min_hash_size < 0" do
      expect_raises Exception, /The min size must be 0 or more/ do
        Hashids.new(min_hash_size: -1)
      end
    end

    it "returns an empty string when encoding an empty array" do
      id = Hashids.new.encode([] of Int32)
      id.should eq("")
    end

    it "returns an empty string when encoding a negative number" do
      id = Hashids.new.encode([-1])
      id.should eq("")

      id = Hashids.new.encode([1, -1])
      id.should eq("")
    end

    it "returns an empty string when encoding non-hex input" do
      id = Hashids.new.encode_hex("z")
      id.should eq("")
    end

    it "returns an empty list for empty string" do
      numbers = Hashids.new.decode("")
      numbers.empty?.should be_true
    end

    it "returns an empty array when hex-decoding invalid id" do
      numbers = Hashids.new.decode_hex("f")
      numbers.empty?.should be_true
    end
  end
end
