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
    actor_ref = ActorRef.new("test_supervisor/test_actor")
    a = system.get(actor_ref).as(TestActor)
    c = a.send(TestMessage.new("abc"))
    c.receive.should eq "1"
  end
end