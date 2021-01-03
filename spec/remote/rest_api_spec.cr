require "../spec_helper"

describe Cavorite do
  # it "create rest api" do
  #  actor_system = Cavorite::Core::System.new("test_system")
  #  actor_ref = actor_system.add("/", TestActor.new("test_actor")).as(ActorRef)
  #  test_message = TestMessage.new("test")
  #
  #  cluster = Cavorite::Remote::K8sCluster.new("test-service")
  #  response_channel = Cavorite::Remote::RestApi.new(cluster).send(actor_ref, test_message, String)
  #  response_channel.receive.should eq "1"
  # end

  it "join" do
    cluster = Cavorite::Remote::K8sCluster.new("test-service")
    rest_api = Cavorite::Remote::RestApi.new(cluster)
    result = rest_api.join(URI.parse("http://127.0.0.1:8080"))
    result.should eq [] of String
    # puts TEST_CLUSTER.nodes
    # response_channel.receive.should eq "1"
  end
end
