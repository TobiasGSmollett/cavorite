module Cavorite::Core
  class ActorRef
    getter system : String
    getter path : String

    def initialize(@system : String, @path : String)
    end

    def to_remote(node : Node)
      remote_actor = RemoteActorRef.new(@system, @path)
      remote_actor.address = node.uri.host
      remote_actor.port = node.uri.port || 8080
    end
  end

  class RemoteActorRef < ActorRef
    getter protocol : String
    property address : String
    property port : Int32
    property path : String

    def initialize(@system : String, @path : String)
      super(@system, @path)
      @protocol = "http"
      @address = "127.0.0.1"
      @port = 8080
    end

    def to_s
      "#{@protocol}://#{@system}@#{@address}:#{@port}/#{@path}"
    end
  end
end
