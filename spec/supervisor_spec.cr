require "./spec_helper"

describe Cavorite do
  it "create supervisor" do
    actor = TestActor.new do |msg|
      msg.as(TestMessage).text + "abc"
    end
    response_channel = actor.send(TestMessage.new("test"))
    response_channel.receive.should eq "testabc"

    supervisor = Supervisor.new(Supervisor::Strategy::OneForOne)
    supervisor.add_child(actor)
  end
end