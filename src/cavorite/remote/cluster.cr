require "socket"
require "uri"

require "../utils/set"

module Cavorite::Remote
  abstract class Cluster
    getter nodes : Cavorite::Utils::Set(Node)

    def initialize(@namespace : String = "default")
      @nodes = Cavorite::Utils::Set(Node).new
      @ping_interval = 1
    end

    def nodes
      @nodes.get
    end

    def join(nodes : Array(Node))
      nodes.each { |node| @nodes.add(node) }
      @nodes.add(Node.new("127.0.0.1"))
    end

    def leave
      # TODO: send leave request to cluster
      @nodes.clear
    end

    def handle_cluster_message(msg : ClusterMessage)
      case msg
      when Ping
      when Join
        result = @nodes.get.to_a.map { |node| node.uri.to_s }
        @nodes.add(msg.sender_node)
        result
      when Leave
        @nodes.delete(msg.sender_node)
      end
    end

  end
end
