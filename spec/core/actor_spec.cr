require "../spec_helper"

describe Cavorite do
  it "create actor" do
    actor = TestActor.new("test_actor")
    test_message = TestMessage.new("test")
    actor.send!(test_message)
    sleep 1
    actor.state.should eq 1
  end

  it "update state in actor" do
    actor = TestActor.new("test_actor")
    2000.times { actor.send!(TestMessage.new("test")) }
    sleep 1
    actor.state.should eq 2000
  end
end
