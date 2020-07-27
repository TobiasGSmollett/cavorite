require "spec"
require "../src/cavorite"
require "../src/cavorite/*"

include Cavorite

class TestActor < Actor(String)
end

class TestMessage < UserMessage

  getter text : String

  def initialize(@text : String)
  end
end