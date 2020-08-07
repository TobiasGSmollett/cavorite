require "http/client"
require "uri"

module Cavorite::HTTP
  module RestApi
    extend self

    def send!(actor_ref : ActorRef, msg : ActorMessage)
      uri = URI.parse(actor_ref.to_s)
      headers = ::HTTP::Headers {
        CAVORITE_ACTOR_SYSTEM_NAME_HEADER => uri.user.as(String),
        CAVORITE_MESSAGE_TYPE_HEADER => msg.message_type,
      }
      spawn { HTTP::Client.post(uri, headers, msg.to_msgpack, nil) }
    end

    def send(actor_ref : ActorRef, msg : ActorMessage, response_type : T.class) forall T
      channel = Channel(T).new
      uri = URI.parse(actor_ref.to_s)
      headers = ::HTTP::Headers { 
        CAVORITE_ACTOR_SYSTEM_NAME_HEADER => uri.user.as(String),
        CAVORITE_MESSAGE_TYPE_HEADER => msg.message_type,
      }
      spawn do 
        response = ::HTTP::Client.post(uri, headers, msg.to_msgpack, nil)
        channel.send(response.body)
      end
      channel
    end
  end
end