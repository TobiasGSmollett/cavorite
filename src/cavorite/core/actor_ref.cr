module Cavorite::Core
  class ActorRef
    getter protocol : String
    getter system : String
    getter address : String
    getter port : Int32
    getter path : String

    def initialize(@system : String, @path : String)
      @protocol = "http"
      @address = "127.0.0.1"
      @port = 8080
    end

    def to_s
      "#{@protocol}://#{@system}@#{@address}:#{@port}/#{@path}"
    end
  end
end