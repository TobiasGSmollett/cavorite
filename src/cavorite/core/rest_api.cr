require "http/client"
require "http/server"
require "uri"
#require "msgpack"

module Cavorite::Core
  class RestApi
    CAVORITE_HEADER = "X-Cavorite-Message-Type"

    @@http_server : HTTP::Server?

    def initialize(port : Int32 = 8080)
      if @@http_server.nil?
        @@http_server = HTTP::Server.new(->http_request_handler(HTTP::Server::Context))
        @@http_server.as(HTTP::Server).bind_tcp port
      end
    end

    def run_server
      @@http_server.as(HTTP::Server).listen
    end

    private def http_request_handler(context : HTTP::Server::Context): Nil
      system_name = context.request.uri.as(URI).user
      # TODO: bugfix
      system_name = "test_system"
      body = context.request.body
      return if body.nil?
      message_type_name = context.request.headers[CAVORITE_HEADER]?
      return if message_type_name.nil?
      message_type = ActorMessageTypeRepository.get(message_type_name)
      return if message_type.nil?
      msg = message_type.from_msgpack(body)
      path = context.request.path.lchop('/')
      actor_ref = ActorRef.new(path)
      actor_ref.system = system_name

      if msg.is_required_response
        Cavorite::Core::System.send!(actor_ref, msg)
      else
        channel = Cavorite::Core::System.send(actor_ref, msg).as(Channel(String))
        response_body = channel.receive
        context.response.print response_body
      end
    end

    def self.send!(actor_ref : ActorRef, msg : ActorMessage)
      uri = URI.parse(actor_ref.to_s)
      headers = HTTP::Headers{ CAVORITE_HEADER => msg.message_type }
      spawn { HTTP::Client.post(uri, headers, msg.to_msgpack, nil) }
    end

    def self.send(actor_ref : ActorRef, msg : ActorMessage, response_type : T.class) forall T
      channel = Channel(T).new
      uri = URI.parse(actor_ref.to_s)
      headers = HTTP::Headers{ CAVORITE_HEADER => msg.message_type }
      spawn do 
        response = HTTP::Client.post(uri, headers, msg.to_msgpack, nil)
        channel.send(response.body)
      end
      channel
    end
  end
end