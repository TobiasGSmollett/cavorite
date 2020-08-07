require "./spec_helper"

describe Cavorite do
  it "create rest api" do
    actor_system = Cavorite::Core::System.new("test_system")
    actor = TestActor.new("test_actor")
    test_message = TestMessage.new("test")

    actor_system.add(actor)
    actor_ref = ActorRef.new("test_system", "test_actor")

    response_channel = Cavorite::HTTP::RestApi.send(actor_ref, test_message, String)
    response_channel.receive.should eq "1"
  end

  #it "parse_actor_ref" do
  #  
  #end
end