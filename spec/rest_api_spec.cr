require "./spec_helper"

describe Cavorite do
  it "create rest api" do
    actor_system = Cavorite::Core::System.new("test_system")
    actor = TestActor.new("test_actor")
    test_message = TestMessage.new("test")

    actor_system.add(actor)

    actor_ref = ActorRef.new("test_actor")
    actor_ref.system = "test_system"

    spawn do
      a = RestApi.new
      a.run_server
    end
    sleep 1
    
    response_channel = RestApi.send(actor_ref, test_message, String)
    response_channel.receive.should eq "1"
  end

  # it "send message via rest api" do
  #   actor = TestActor.new("test_actor")
  #   (1..1999).each { |i| actor.send!(TestMessage.new("test"))}
  #   response_channel = actor.send(TestMessage.new("test"))
  #   response_channel.receive.should eq 2000.to_s
  # end
end