require "../spec_helper"

describe Cavorite do
  it "create supervisor" do
    actor = TestActor.new("test_actor")
    response_channel = actor.send(TestMessage.new("test"))
    response_channel.receive.should eq "1"

    supervisor = Supervisor.new("test_supervisor", Supervisor::Strategy::OneForOne)
    supervisor.add_child(actor)
  end
end