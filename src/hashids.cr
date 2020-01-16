require "big/big_int"
require "big/lib_gmp"

class Hashids
  VERSION = "1.0.5"

  MIN_ALPHABET_SIZE =   16
  SEP_DIV           =  3.5
  GUARD_DIV         = 12.0

  DEFAULT_SEPS = "cfhistuCFHISTU"

  DEFAULT_ALPHABET = "abcdefghijklmnopqrstuvwxyz" +
                     "ABCDEFGHIJKLMNOPQRSTUVWXYZ" +
                     "1234567890"

  @salt : String
  @min_hash_size : Int32
  @alphabet : String
  @seps : String = DEFAULT_SEPS
  @guards : String = ""
  getter :salt, :min_hash_size, :alphabet, :seps, :guards

  def initialize(@salt = "", @min_hash_size = 0, @alphabet = DEFAULT_ALPHABET)
    setup_alphabet
  end

  #########
  # SETUP #
  #########
  private def setup_alphabet
    raise "The min size must be 0 or more" unless min_hash_size >= 0
    raise "The alphabet can’t include spaces" if alphabet.includes?(" ")

    @alphabet = @alphabet.split("").uniq.join("")

    validate_alphabet
    setup_seps
    setup_guards
  end

  private def validate_alphabet
    unless alphabet.size >= MIN_ALPHABET_SIZE
      raise "Alphabet must contain at least #{MIN_ALPHABET_SIZE} unique characters."
    end
  end

  private def setup_seps
    @seps = DEFAULT_SEPS

    seps.size.times do |i|
      # Seps should only contain characters present in alphabet,
      # and alphabet should not contains seps
      if j = alphabet.index(seps[i])
        @alphabet = pick_characters(alphabet, j)
      else
        @seps = pick_characters(seps, i)
      end
    end

    @alphabet = @alphabet.delete(" ")
    @seps = @seps.delete(" ")

    @seps = consistent_shuffle(seps, salt)

    if seps.size == 0 || (alphabet.size / seps.size.to_f) > SEP_DIV
      seps_size = (alphabet.size / SEP_DIV).ceil
      seps_size = 2 if seps_size == 1

      if seps_size > seps.size
        diff = (seps_size - seps.size).to_i64
        @seps += alphabet[0, diff]
        @alphabet = alphabet[diff..-1]
      else
        @seps = seps[0, seps_size.to_i64]
      end
    end

    @alphabet = consistent_shuffle(alphabet, salt)
  end

  private def pick_characters(array, index)
    array[0, index] + " " + array[index + 1..-1]
  end

  protected def consistent_shuffle(alphabet, salt)
    return alphabet if salt.nil? || salt.empty?

    chars = alphabet.each_char.to_a
    salt_ords = salt.codepoints
    salt_size = salt_ords.size
    idx = ord_total = 0

    (alphabet.size - 1).downto(1) do |i|
      ord_total += n = salt_ords[idx]
      j = (n + idx + ord_total) % i

      chars[i], chars[j] = chars[j], chars[i]

      idx = (idx + 1) % salt_size
    end

    chars.join
  end

  private def setup_guards
    gc = (alphabet.size / GUARD_DIV).ceil.to_i64

    if alphabet.size < 3
      @guards = seps[0, gc]
      @seps = seps[gc..-1]
    else
      @guards = alphabet[0, gc]
      @alphabet = alphabet[gc..-1]
    end
  end

  ##########
  # Encode #
  ##########
  def encode(numbers : Array(Int))
    numbers = numbers.flatten if numbers.size == 1
    return "" if numbers.empty? || numbers.any? { |n| n < 0 }
    internal_encode(numbers)
  end

  protected def internal_encode(numbers : Array(Int))
    ret = ""

    alphabet = @alphabet
    size = numbers.size
    hash_int = 0

    size.times do |i|
      hash_int += (numbers[i] % (i + 100))
    end

    lottery = ret = alphabet[hash_int % alphabet.size]

    size.times do |i|
      num = numbers[i]
      buf = lottery + salt + alphabet

      alphabet = consistent_shuffle(alphabet, buf[0, alphabet.size])
      last = hash(num, alphabet)

      ret += last

      if (i + 1) < size
        num %= (last[0].ord + i)
        ret += seps[num % seps.size]
      end
    end
    ret = ret.to_s

    if ret.size < min_hash_size
      ret = guards[(hash_int + ret[0].ord) % guards.size] + ret

      if ret.size < min_hash_size
        ret += guards[(hash_int + ret[2].ord) % guards.size]
      end
    end

    half_size = alphabet.size.tdiv(2)

    while (ret.size < min_hash_size)
      alphabet = consistent_shuffle(alphabet, alphabet)
      ret = alphabet[half_size..-1] + ret + alphabet[0, half_size]

      excess = ret.size - min_hash_size
      ret = ret[(excess / 2).to_i64, min_hash_size] if excess > 0
    end

    ret
  end

  protected def hash(input, alphabet)
    num = input.to_i64
    len = alphabet.size
    res = ""

    loop do
      res = "#{alphabet[num % len]}#{res}"
      num = num.tdiv(alphabet.size)
      break if num == 0
    end

    res
  end

  ##############
  # Encode Hex #
  ##############
  def encode_hex(hex : String)
    return "" unless hex.match(/\A[0-9a-fA-F]+\z/)

    numbers = hex.scan(/[\w\W]{1,12}/).map do |num|
      "1#{num[0]}".to_big_i(16)
    end

    encode(numbers)
  end

  ##########
  # Decode #
  ##########
  def decode(hash : String) : Array(Int64)
    return [] of Int64 if hash.nil? || hash.empty?

    internal_decode(hash, @alphabet)
  end

  protected def internal_decode(hash : String, alphabet : String) : Array(Int64)
    ret = [] of Int64

    breakdown = hash.tr(@guards, " ")
    array = breakdown.split(" ")

    i = [3, 2].includes?(array.size) ? 1 : 0

    if breakdown = array[i]
      lottery = breakdown[0]
      breakdown = breakdown[1..-1].tr(@seps, " ")
      array = breakdown.split(" ")

      array.size.times do |time|
        sub_hash : String = array[time]
        buffer : String = lottery + salt + alphabet
        alphabet = consistent_shuffle(alphabet, buffer[0, alphabet.size])

        ret.push unhash(sub_hash, alphabet)
      end

      if encode(ret) != hash
        ret = [] of Int64
      end
    end

    ret
  end

  protected def unhash(input : String, alphabet : String)
    num : Int64 = 0

    input.size.times do |i|
      pos : Int64? = alphabet.index(input[i]).try &.to_i64

      raise "unable to unhash" unless pos

      num += pos * alphabet.size.to_i64 ** (input.size - i - 1).to_i64
    end

    num
  end

  ##############
  # Decode Hex #
  ##############
  def decode_hex(id : String)
    String.build(id.bytesize) do |ret|
      numbers = decode(id)
      numbers.each do |number|
        ret << number.to_s(16)[1..-1]
      end
    end
  end
end
