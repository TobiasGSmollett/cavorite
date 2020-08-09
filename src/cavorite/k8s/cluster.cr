require "socket"
require "uri"

module Cavorite::K8s
  class Cluster

    # TODO: uses non-blocking skip list
    @node_list : Set(Node)
    @ping_interval

    def initialize(@service : String, @namespace : String = "default")
      @node_list = Set(Node).new
      @ping_interval = 1
    end

    def ip_address_list
      domain =  "#{@service}.#{@namespace}.svc.cluster.local"
      Socket::Addrinfo.resolve(domain, 53, type: Socket::Type::STREAM)
      .map { |addrinfo| addrinfo.ip_address.address }
    end

    def join
    end

    def leave
    end

    def node_list
    end

    def ping
      spawn do
        loop do
          sleep @ping_interval
          @node_list.each do |node|
            ::HTTP::Client.post(node.uri) do |response|
              if response.status_code != 200
                @node_list.delete(node)
              end
            end
          end
        end
      end
    end
  end

  class Node
    getter protocol : String
    getter host : String
    getter port : Int32

    def initialize(@host : String, @port : Int32 = 8080)
      @protocol = "http"
    end

    def uri : URI
      URI.parse "#{@protocol}://#{host}:#{port}"
    end

    def ==(other : Node)
      @protocol == other.protocol &&
      @host == other.host &&
      @port == other.port
    end
  end
end
