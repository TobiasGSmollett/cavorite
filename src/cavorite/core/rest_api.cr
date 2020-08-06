require "http/client"
require "http/server"
require "uri"
#require "msgpack"

module Cavorite::Core
  class RestApi
    CAVORITE_HEADER = "X-Cavorite-Message-Type"

    @@http_server : HTTP::Server?
    @@message_types = {} of String => ActorMessage.class

    def self.message_type(type_name : String)
      @@message_types[type_name]
    end

    def initialize(port : Int32 = 8080)
      if @@http_server.nil?
        @@http_server = HTTP::Server.new(->http_request_handler(HTTP::Server::Context))
        @@http_server.as(HTTP::Server).bind_tcp port
      end

      if @@message_types.empty?
        ActorMessage.all_message_types.each do |message_type|
          @@message_types[message_type.to_s] = message_type
        end
      end
    end

    private def http_request_handler(context : HTTP::Server::Context): Nil
      system_name = context.request.@uri.as(URI).user
      body = context.request.body
      return if body.nil?
      
      message_type_name = context.request.headers[CAVORITE_HEADER]?
      return if message_type_name.nil?
      message_type = @@message_types[message_type_name]?
      return if message_type.nil?
      msg = message_type.from_msgpack(body)
      actor_ref = ActorRef.new(context.request.path)
      Cavorite::Core::System.send(actor_ref, msg)
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