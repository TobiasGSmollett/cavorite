require "../spec_helper"

describe Cavorite do
  it "create K8sCluster" do
    cluster = Cavorite::Remote::K8sCluster.new("test-service")
  end

  it "join" do
    cluster = Cavorite::Remote::K8sCluster.new("test-service")
    cluster.join([
      Cavorite::Remote::Node.new("aaaa"),
      Cavorite::Remote::Node.new("bbbb"),
      Cavorite::Remote::Node.new("cccc"),
    ])

    expected = [
      "http://aaaa:8080",
      "http://bbbb:8080",
      "http://cccc:8080",
      "http://127.0.0.1:8080",
    ]

    cluster.nodes.map { |node| node.uri.to_s }.should eq expected
  end

  it "handle join message" do
    cluster = Cavorite::Remote::K8sCluster.new("test-service")

    join_message1 = Cavorite::Core::Join.new("http://aaaa/system1")
    join_message2 = Cavorite::Core::Join.new("http://aaaa/system2")
    join_message3 = Cavorite::Core::Join.new("http://bbbb/system1")
    join_message4 = Cavorite::Core::Join.new("http://cccc/system1")

    cluster.handle_cluster_message(join_message1)
    cluster.handle_cluster_message(join_message2)
    cluster.handle_cluster_message(join_message3)
    all_nodes = cluster.handle_cluster_message(join_message4)

    expected = [
      "http://aaaa:8080",
      "http://bbbb:8080",
    ]

    all_nodes.should eq expected
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
