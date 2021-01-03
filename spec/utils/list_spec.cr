require "../spec_helper"

describe Cavorite do
  it "add on single thread" do
    str = "abcdefghijklmn"
    str2 = "123456"

    list = List(String).new
    list.add(str).should eq true
    list.add(str2).should eq true
  end

  it "contains on single thread" do
    str = "abcdefghijklmn"
    str2 = "123456"
    list = List(String).new
    list.add(str)
    list.add(str2)

    list.contains(str).should eq true
    list.contains(str2).should eq true
    list.contains("aaaaaa").should eq false
  end

  it "removes on single thread" do
    str = "abcdefghijklmn"
    str2 = "123456"
    list = List(String).new
    list.add(str)
    list.add(str2)

    list.remove(str)

    list.contains(str).should eq false
    list.contains(str2).should eq true

    list.remove(str2)

    list.contains(str2).should eq false
  end
end
