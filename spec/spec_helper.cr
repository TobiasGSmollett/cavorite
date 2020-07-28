require "spec"
require "../src/cavorite"
require "../src/cavorite/*"
require "../src/cavorite/core/*"
require "../src/cavorite/ext/*"
require "../src/cavorite/utils/*"


include Cavorite::Core
include Cavorite::Utils

class TestActor < Actor(Int32, String)
  def handler(state : Int32, msg : ActorMessage): {Int32, String}
    new_state = state + 1
    result = new_state.to_s
    {new_state, result}
  end
end

class TestMessage < UserMessage

  getter text : String

  def initialize(@text : String)
  end
end