require "../spec_helper"

describe Cavorite do
  it "create K8sCluster" do
    cluster = Cavorite::Remote::K8sCluster.new("test-service")
  end

  it "handle join/leave message" do
    cluster = Cavorite::Remote::K8sCluster.new("test-service")

    join_message1 = Cavorite::Core::Join.new("http://aaaa/system1")
    join_message2 = Cavorite::Core::Join.new("http://aaaa/system2")
    join_message3 = Cavorite::Core::Join.new("http://bbbb/system1")
    join_message4 = Cavorite::Core::Join.new("http://cccc/system1")

    cluster.handle_cluster_message(join_message1)
    cluster.handle_cluster_message(join_message2)
    cluster.handle_cluster_message(join_message3)
    cluster.handle_cluster_message(join_message4)

    expected = [
      Cavorite::Remote::Node.new(join_message1.uri),
      Cavorite::Remote::Node.new(join_message3.uri),
      Cavorite::Remote::Node.new(join_message4.uri),
    ]

    cluster.nodes.to_a.should eq expected

    leave_message3 = Cavorite::Core::Leave.new("http://bbbb/system1")
    cluster.handle_cluster_message(leave_message3)

    expected = [
      Cavorite::Remote::Node.new(join_message1.uri),
      Cavorite::Remote::Node.new(join_message4.uri),
    ]

    cluster.nodes.to_a.should eq expected
  end
end