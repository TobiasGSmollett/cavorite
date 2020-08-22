require "../spec_helper"

describe Cavorite do
  it "create rest api" do
    actor_system = Cavorite::Core::System.new("test_system")
    actor_ref = actor_system.add("/", TestActor.new("test_actor")).as(ActorRef)
    test_message = TestMessage.new("test")

    response_channel = Cavorite::Remote::RestApi.send(actor_ref, test_message, String)
    response_channel.receive.should eq "1"
  end

  #it "parse_actor_ref" do
  #  
  #end
end