require "benchmark"

require "../src/hashids"

def run_benchmarks(title, numbers : Array(Int), **kwargs)
  hashids = Hashids.new(**kwargs)
  id = hashids.encode(numbers)

  Benchmark.ips do |x|
    x.report "#{title}: encode" do
      hashids.encode(numbers)
    end

    x.report "#{title}: decode" do
      hashids.decode(id)
    end
  end
end

def run_benchmarks(title, hex, **kwargs)
  hashids = Hashids.new(**kwargs)
  id = hashids.encode_hex(hex)

  Benchmark.ips do |x|
    x.report "#{title}: encode_hex" do
      hashids.encode_hex(hex)
    end

    x.report "#{title}: decode_hex" do
      hashids.decode_hex(id)
    end
  end
end

run_benchmarks("simple single big int", [9007199254740991])
run_benchmarks("deadbeef", "deadbeef")
run_benchmarks("simple array 3", [1, 2, 3])
