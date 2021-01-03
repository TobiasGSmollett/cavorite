require "../spec_helper"

describe Cavorite do
  it "single thread" do
    set = Cavorite::Utils::Set(String).new
    set.add("a")
    set.add("b")
    set.add("c")

    expected = ["a", "b", "c"]

    set.each do |ch|
      ch.should eq expected[0]
      expected.shift
    end
  end
end
