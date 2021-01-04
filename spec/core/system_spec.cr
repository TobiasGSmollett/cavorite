require "../spec_helper"

describe Cavorite do
  it "create system 1" do
    system = Cavorite::Core::System.new("test_system")
    actor = TestActor.new("test_actor")
    supervisor = Supervisor.new(
      "test_supervisor",
      Supervisor::Strategy::OneForOne,
      [ actor ]
    )
  
    system.add("/", supervisor)
    actor_ref = ActorRef.new("test_system", "test_supervisor/test_actor")
    test_message = TestMessage.new("abc")
    Cavorite::Core::System.send!(actor_ref, test_message)
    sleep 1
    actor.state.should eq 1
  end

  it "create system 2" do
    system = Cavorite::Core::System.new("test_system")
    system.create("/", "test_supervisor", Supervisor)
    actor_ref = system.create("/test_supervisor", "test_actor", TestActor).as(ActorRef)
    test_message = TestMessage.new("abc")
    Cavorite::Core::System.send!(actor_ref, test_message)
  end
end
