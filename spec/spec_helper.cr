require "spec"
require "../src/hashids"

def test_hashids_roundtrip(**kwargs)
  hashids = Hashids.new(**kwargs)
  numbers = [1, 2, 3]

  id = hashids.encode(numbers)
  hashids.decode(id).should eq(numbers)
  id
end
