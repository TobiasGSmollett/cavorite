require "../spec_helper"

describe Cavorite do

  it "single thread" do
    str = "abcdefghijklmn"
    str2 = "123456"

    list = List(String).new()
    list.add(str)
    list.add(str2)
    list.contains(str).should eq true
    list.contains(str2).should eq true
    list.contains("aaaaaa").should eq false
  end
end