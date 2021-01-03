require "http/client"
require "json"
require "uri"

module Cavorite::Remote
  class RestApi
    @cluster : Cavorite::Remote::Cluster

    def initialize(@cluster)
    end

    # def health_check
    #  spawn do
    #    loop do
    #      sleep @ping_interval
    #      @cluster.nodes.each do |node|
    #        spawn { @nodes.delete(node) unless ping(node) }
    #      end
    #    end
    #  end
    # end

    def ping(uri : URI)
      # TODO: error handling
      ::HTTP::Client.post(uri) do |response|
        return response.status_code != 200
      end
    end

    def join(uri : URI) : Array(String)
      msg = Join.new(uri.to_s)
      headers = ::HTTP::Headers{CAVORITE_MESSAGE_TYPE_HEADER => msg.message_type}
      channel = Channel(Array(String)).new
      spawn do
        response = ::HTTP::Client.post(uri, headers, msg.to_msgpack, nil)
        node_uri_list = JSON.parse(response.body).as_a.map { |node| node.as_s }
        channel.send(node_uri_list)
      end
      channel.receive
    end

    def leave
      @cluster.nodes.each { |node| leave(node) }
    end

    def leave(node : Node)
      uri = node.uri
      msg = Leave.new(uri.to_s)
      headers = ::HTTP::Headers{CAVORITE_MESSAGE_TYPE_HEADER => msg.message_type}
      spawn do
        HTTP::Client.post(uri, headers, msg.to_msgpack, nil)
      end
    end

    def send!(actor_ref : ActorRef, msg : ActorMessage)
      uri = URI.parse(actor_ref.to_s)
      headers = ::HTTP::Headers{
        CAVORITE_ACTOR_SYSTEM_NAME_HEADER => uri.user.as(String),
        CAVORITE_MESSAGE_TYPE_HEADER      => msg.message_type,
      }
      spawn { HTTP::Client.post(uri, headers, msg.to_msgpack, nil) }
    end

    def broadcast!(actor_ref : ActorRef, msg : ActorMessage)
      @cluster.nodes.each do |node|
        uri = remote_actor_ref.to_remote(node).uri
        # msg.sender =
        headers = ::HTTP::Headers{
          CAVORITE_ACTOR_SYSTEM_NAME_HEADER => uri.user.as(String),
          CAVORITE_MESSAGE_TYPE_HEADER      => msg.message_type,
        }
        spawn { HTTP::Client.post(uri, headers, msg.to_msgpack, nil) }
      end
    end
  end
end
