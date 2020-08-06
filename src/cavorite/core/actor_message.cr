require "msgpack"

module Cavorite::Core
  class ActorMessage
    @is_required_response : Bool = false
    @message_type : String = {{ @type.name.stringify }}

    property is_required_response : Bool

    property message_type : String

    def self.all_message_types
      {{ @type.all_subclasses }}
    end

    def self.from_msgpack(io : IO)
      h = Hash(String, MessagePack::Type).from_msgpack(io)
      
      instance = {{ @type.name }}.allocate
      {% for var in @type.instance_vars %}
      instance.{{ var.name }} = h["{{ var.name }}"].as({{var.type.name}})
      {% end %}
      instance
    end
  end

  class SystemMessage < ActorMessage
  end

  class Die < SystemMessage
  end

  class Restart < SystemMessage
    def initialize
    end
  end

  class UserMessage < ActorMessage
  end

  module ActorMessageTypeRepository
    extend self

    @@message_types = {} of String => ActorMessage.class

    def init
      return if !@@message_types.empty?
      ActorMessage.all_message_types.each do |message_type|
        @@message_types[message_type.to_s] = message_type
      end
    end

    def get(message_type_name : String)
      @@message_types[message_type_name]?
    end
  end
end

ActorMessageTypeRepository.init