require "../spec_helper"

describe Cavorite do

  it "single thread" do
    ref = AtomicMarkableReference(String).new("test")
    
    ref.get.should eq({"test", false})
    
    ref.compare_and_set("test", "new", false, true)
    
    ref.get.should eq({"new", true})
    
    ref.attempt_mark("new", false).should eq true
    ref.get.should eq({"new", false})
  end
end