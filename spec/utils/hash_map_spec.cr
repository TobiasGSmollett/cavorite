require "../spec_helper"

describe Cavorite do

  it "single thread" do
    hash_map = HashMap(String, Int32).new
    hash_map["a"] = 1
    hash_map["b"] = 2
    hash_map["c"] = 3

    hash_map["a"].should eq 1
    hash_map["b"].should eq 2
    hash_map["c"].should eq 3
  end
end