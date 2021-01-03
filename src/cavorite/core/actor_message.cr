require "uri"

require "msgpack"

module Cavorite::Core
  class ActorMessage
    # uri string of actor
    @sender : String = ""
    property sender : String

    macro inherited
    @message_type : String = {{ @type.name.stringify }}
    property message_type : String
    end

    def self.all_message_types
      {{ @type.all_subclasses }}
    end

    def to_msgpack
      h = Hash(String, MessagePack::Type).new
      {% for var in @type.instance_vars %}
      h["{{ var.name }}"] = @{{ var.name }}
      {% end %}
      h.to_msgpack
    end

    def self.from_msgpack(io : IO)
      h = Hash(String, MessagePack::Type).from_msgpack(io)

      instance = {{ @type.name }}.allocate
      {% for var in @type.instance_vars %}
      instance.{{ var.name }} = h["{{ var.name }}"].as({{var.type.name}})
      {% end %}
      instance
    end

    def sender=(uri : URI)
      @sender = uri.to_s
    end

    def sender : URI
      return nil if @sender.nil?
      # TODO: error handling
      URI.parse(@sender)
    end
  end

  class SystemMessage < ActorMessage
  end

  class Die < SystemMessage
  end

  class ClusterMessage < SystemMessage
  end

  class Join < ClusterMessage
    property uri_string : String

    def initialize(@uri_string : String)
    end

    def uri : URI
      URI.parse(uri_string)
    end

    def sender_node
      Cavorite::Remote::Node.new(uri)
    end
  end

  class Leave < ClusterMessage
    property uri_string : String

    def initialize(@uri_string : String)
    end

    def uri : URI
      URI.parse(uri_string)
    end

    def sender_node
      Cavorite::Remote::Node.new(uri)
    end
  end

  class Ping < ClusterMessage
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

Cavorite::Core::ActorMessageTypeRepository.init
