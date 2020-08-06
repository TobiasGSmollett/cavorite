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
end