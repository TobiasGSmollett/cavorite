require "./spec_helper"

describe Cavorite do
  it "create system" do
    system = Cavorite::Core::System.new("test_system")

    supervisor = Supervisor.new(
      "test_supervisor",
      Supervisor::Strategy::OneForOne,
      [
        TestActor.new("test_actor")
      ]
    )
    
    system.add(supervisor)
    actor_ref = ActorRef.new("test_system", "test_supervisor/test_actor")
    test_message = TestMessage.new("abc")
    c = Cavorite::Core::System.send(actor_ref, test_message).as(Channel(String))
    c.receive.should eq "1"
  end
end