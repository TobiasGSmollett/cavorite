require "http/client"
require "http/server"
require "uri"

module Cavorite
  class RestApi
    CAVORITE_HEADER = "X-Cavorite-Message-Type"

    @@http_server : HTTP::Server?
    @@message_types : Array(ActorMessage.class) = [] of ActorMessage.class

    def initialize
      if @@http_server.nil?
        @@http_server = HTTP::Server.new(->http_request_handler(HTTP::Server::Context))
        @@http_server.as(HTTP::Server).bind_tcp 8080
      end      
    end

    private def http_request_handler(context : HTTP::Server::Context): Nil
      system_name = context.request.@uri.as(URI).user
      path = context.request.path
      message_type_name = context.request.headers[CAVORITE_HEADER]?
      return if message_type.nil?
      message_type = @@message_types[message_type_name]?
      return if message_type.nil?
      body = context.request.body
      msg = message_type.from_msgpack(body)
      Cavorite::Core::System.send(msg)
    end

    def self.send!(actor_ref : ActorRef, msg : ActorMessage)
      uri = URI.parse(actor_ref.to_s)
      headers = HTTP::Headers{ CAVORITE_HEADER => msg.message_type }
      spawn { HTTP::Client.post(uri, headers, msg.to_msgpack, nil) }
    end

    def self.send(actor_ref : ActorRef, msg : ActorMessage, response_type : T.class) forall T
      channel = Channle(T).new
      uri = URI.parse(actor_ref.to_s)
      headers = HTTP::Headers{ CAVORITE_HEADER => msg.message_type }
      spawn do 
        response = HTTP::Client.post(uri, headers, msg.to_msgpack, nil)
        unpacked_response = T.from_msgpack(response.body)
        channel.send(unpacked_response)
      end
      channel
    end
  end
end