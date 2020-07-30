require "./spec_helper"

describe Cavorite do
  it "create system" do
    system = Cavorite::Core::System.new("test_system")

    supervisor = Supervisor.new("test_supervisor", Supervisor::Strategy::OneForOne)
    actor = TestActor.new("test_actor")
    
    supervisor.add_child(actor)

    system.add(supervisor)
    actor_ref = ActorRef.new("test_supervisor/test_actor")

    a = system.get(actor_ref)
    (!a.nil? && a.same?(actor)).should eq true
  end
end