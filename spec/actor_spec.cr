require "./spec_helper"

describe Cavorite do
  it "create actor" do
    actor = TestActor.new(0)
    response_channel = actor.send(TestMessage.new("test"))
    response_channel.receive.should eq "1"
  end

  it "update state in actor" do
    actor = TestActor.new(0)
    (1..1999).each { |i| actor.send!(TestMessage.new(""))}
    response_channel = actor.send(TestMessage.new(""))
    response_channel.receive.should eq 2000.to_s
  end
end