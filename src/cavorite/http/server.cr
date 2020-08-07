require "http/client"
require "http/server"
require "uri"

module Cavorite::HTTP
  module Server
    extend self

    @@http_server : ::HTTP::Server?

    def run(port : Int32 = 8080)
      if @@http_server.nil?
        @@http_server = ::HTTP::Server.new(->request_handler(::HTTP::Server::Context))
      end
      @@http_server.as(::HTTP::Server).bind_tcp port
      spawn { @@http_server.as(::HTTP::Server).listen }
    end

    # :nodoc:
    def request_handler(context : ::HTTP::Server::Context)
      msg = parse_actor_message(context)
      actor_ref = parse_actor_ref(context)

      return if msg.nil? || actor_ref.nil?

      if msg.is_required_response
        Cavorite::Core::System.send!(actor_ref, msg)
      else
        channel = Cavorite::Core::System.send(actor_ref, msg).as(Channel(String))
        response_body = channel.receive
        context.response.print response_body
      end
    end

    # :nodoc:
    def parse_actor_ref(context : ::HTTP::Server::Context)
      system_name = context.request.headers[CAVORITE_ACTOR_SYSTEM_NAME_HEADER]?
      return if system_name.nil?
      path = context.request.path.lchop('/')
      ActorRef.new(system_name, path)
    end

    # :nodoc:
    def parse_actor_message(context : ::HTTP::Server::Context)
      body = context.request.body
      return if body.nil?
      message_type_name = context.request.headers[CAVORITE_MESSAGE_TYPE_HEADER]?
      return if message_type_name.nil?
      message_type = ActorMessageTypeRepository.get(message_type_name)
      return if message_type.nil?
      message_type.from_msgpack(body)
    end
  end
end