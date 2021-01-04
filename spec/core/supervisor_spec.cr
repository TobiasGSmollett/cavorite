require "../spec_helper"

describe Cavorite do
  it "create supervisor" do
   actor = TestActor.new("test_actor")
  
   supervisor = Supervisor.new("test_supervisor", Supervisor::Strategy::OneForOne)
   supervisor.add_child(actor)
  end
end
