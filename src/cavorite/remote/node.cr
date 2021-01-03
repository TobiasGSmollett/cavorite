module Cavorite::Remote
  struct Node
    DEFAULT_PROTOCOL = "http"
    DEFAULT_PORT     = 8080

    getter protocol : String
    getter host : String
    getter port : Int32

    def initialize(@host : String, @port : Int32 = DEFAULT_PORT)
      @protocol = DEFAULT_PROTOCOL
    end

    def initialize(uri : URI)
      # TODO: validate uri
      @protocol = uri.scheme || DEFAULT_PROTOCOL
      @host = uri.host || ""
      @port = uri.port || DEFAULT_PORT
    end

    def uri : URI
      URI.parse "#{@protocol}://#{host}:#{port}"
    end

    def ==(other : Node)
      @protocol == other.protocol &&
        @host == other.host &&
        @port == other.port
    end
  end
end
