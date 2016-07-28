require "big_int"

class Hashids
  MIN_ALPHABET_LENGTH =   16
  SEP_DIV             =  3.5
  GUARD_DIV           = 12.0

  DEFAULT_SEPS = "cfhistuCFHISTU"

  DEFAULT_ALPHABET = "abcdefghijklmnopqrstuvwxyz" +
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ" +
    "1234567890"

  @salt : String
  @alphabet : String
  @seps : String
  @guards : String

  def initialize(@salt = "", @min_length = 0, alphabet = DEFAULT_ALPHABET)
    validate!(alphabet, @min_length)
    alphabet = unique_alphabet(alphabet)
    @alphabet, @seps, @guards = setup(alphabet, DEFAULT_SEPS)
  end

  def encode(numbers : Array(Int))
    return "" if numbers.empty? || numbers.any? &.< 0
    _encode(numbers)
  end

  def decode(id : String)
    return [] of Int32 if id.empty?
    _decode(id)
  end

  def encode_hex(hex : String)
    return "" unless hex.match(/\A[0-9a-fA-F]+\z/)

    numbers = hex.scan(/[\w\W]{1,12}/).map do |num|
      "1#{num[0]}".to_big_i(16)
    end

    encode(numbers)
  end

  def decode_hex(id : String)
    ret = ""
    numbers = decode(id)

    numbers.size.times do |i|
      ret += numbers[i].to_s(16)[1..-1]
    end

    ret
  end

  private def _encode(numbers)
    numbers_id = 0
    alphabet = @alphabet

    numbers.size.times.each do |i|
      numbers_id += (numbers[i] % (i + 100))
    end

    lottery = ret = alphabet[numbers_id % alphabet.size, 1]

    numbers.size.times.each do |i|
      number = numbers[i]
      buffer = lottery + @salt + alphabet

      alphabet = _shuffle(alphabet, buffer[0, alphabet.size])
      last = _to_alphabet(number, alphabet)

      ret += last

      if i + 1 < numbers.size
        number %= (last[0].ord + i)
        sepsIndex = number % @seps.size
        ret += @seps[sepsIndex]
      end
    end

    if ret.size < @min_length
      guard_index = (numbers_id + ret[0].ord) % @guards.size
      guard = @guards[guard_index]

      ret = guard + ret

      if ret.size < @min_length
        guard_index = (numbers_id + ret[2].ord) % @guards.size
        guard = @guards[guard_index]
        ret += guard
      end
    end

    half_length = alphabet.size / 2
    while ret.size < @min_length
      alphabet = _shuffle(alphabet, alphabet)
      ret = alphabet[half_length..-1] + ret + alphabet[0, half_length]

      excess = ret.size - @min_length
      if excess > 0
        ret = ret[excess / 2, @min_length]
      end
    end

    ret
  end

  private def _decode(id)
    salt = @salt
    alphabet = @alphabet

    ret = [] of BigInt
    i = 0
    id_breakdown = id.gsub(/[#{@guards}]/, " ")
    id_array = id_breakdown.split(" ")

    i = 1 if [3, 2].includes?(id_array.size)

    if id_breakdown = id_array[i]
      lottery = id_breakdown[0]
      id_breakdown = id_breakdown[1..-1].gsub(/[#{@seps}]/, " ")
      id_array = id_breakdown.split(" ")

      id_array.size.times do |i|
        sub_id = id_array[i]
        buffer = lottery + salt + alphabet
        alphabet = _shuffle(alphabet, buffer[0, alphabet.size])

        ret.push _from_alphabet(sub_id, alphabet)
      end

      if encode(ret) != id
        ret = [] of BigInt
      end
    end

    return ret
  end

  private def _shuffle(alphabet, salt)
    return alphabet if salt.empty?

    v = 0
    p = 0

    (alphabet.size - 1).downto(1) do |i|
      v = v % salt.size
      p += n = salt[v].ord
      j = (n + v + p) % i

      tmp_char = alphabet[j]

      alphabet = alphabet[0, j] + alphabet[i] + alphabet[j + 1..-1]
      alphabet = alphabet[0, i] + tmp_char + alphabet[i + 1..-1]

      v += 1
    end

    alphabet
  end

  private def _to_alphabet(input, alphabet)
    id = ""

    id = alphabet[input % alphabet.size] + id
    input = input / alphabet.size

    while input > 0
      id = alphabet[input % alphabet.size] + id
      input = input / alphabet.size
    end

    id
  end

  private def _from_alphabet(input, alphabet)
    num = BigInt.new(0)
    alphabet_size = BigInt.new(alphabet.size)

    input.size.times do |i|
      pos = alphabet.index(input[i])

      raise Exception.new "unable to unhash" unless pos

      num += pos * alphabet_size ** (input.size - i - 1)
    end

    num
  end

  private def unique_alphabet(alphabet)
    alphabet.split("").uniq.join("")
  end

  private def validate!(alphabet, min_length)
    if alphabet.includes?(' ')
      raise Exception.new "The alphabet can't include spaces"
    end

    unless alphabet.size >= MIN_ALPHABET_LENGTH
      raise Exception.new "Alphabet must contain at least " +
        "#{MIN_ALPHABET_LENGTH} unique characters."
    end

    if min_length < 0
      raise Exception.new "The min length must be 0 or more"
    end
  end

  private def setup(alphabet, seps)
    alphabet, seps = setup_seps(alphabet, seps)
    setup_guards(alphabet, seps)
  end

  private def setup_seps(alphabet, seps)
    seps.size.times do |i|
      # Seps should only contain characters present in alphabet,
      # and alphabet should not contains seps
      if j = alphabet.index(seps[i])
        alphabet = pick_characters(alphabet, j)
      else
        seps = pick_characters(seps, i)
      end
    end

    alphabet = alphabet.delete(' ')
    seps = seps.delete(' ')

    seps = _shuffle(seps, @salt)

    if seps.size == 0 || (alphabet.size / seps.size.to_f) > SEP_DIV
      seps_length = (alphabet.size / SEP_DIV).ceil.to_big_i
      seps_length = 2 if seps_length == 1

      if seps_length > seps.size
        diff = (seps_length - seps.size).to_big_i

        seps += alphabet[0, diff]
        alphabet = alphabet[diff..-1]
      else
        seps = seps[0, seps_length]
      end
    end

    alphabet = _shuffle(alphabet, @salt)

    {alphabet, seps}
  end

  private def setup_guards(alphabet, seps)
    gc = (alphabet.size / GUARD_DIV).ceil.to_big_i

    if alphabet.size < 3
      {alphabet, seps[gc..-1], seps[0, gc]}
    else
      {alphabet[gc..-1], seps, alphabet[0, gc]}
    end
  end

  def pick_characters(array, index)
    array[0, index] + " " + array[index + 1..-1]
  end
end
