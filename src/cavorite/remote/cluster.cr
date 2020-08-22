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

    def health_check
      spawn do
        loop do
          sleep @ping_interval
          @nodes.each do |node| 
            spawn { @nodes.delete(node) unless ping(node) }
          end
        end
      end
    end

    def join(node : Node)
      # TODO: send join request to cluster
      @nodes << Node.new("127.0.0.1")
    end

    def leave
      # TODO: send leave request to cluster
      @nodes.clear
    end

    def ping(node : Node)
      # TODO: error handling
      ::HTTP::Client.post(node.uri) do |response|
        return response.status_code != 200
      end
    end

    def handle_cluster_message(msg : ClusterMessage)
      case msg
      when Ping
      when Join
        @nodes.add(msg.sender_node)
        # TODO: send nodes in cluster to sender node
      when Leave
        @nodes.delete(msg.sender_node)
      end
    end
  end
end
