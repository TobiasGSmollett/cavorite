require "spec"
require "../src/cavorite"
require "../src/cavorite/*"
require "../src/cavorite/core/*"
require "../src/cavorite/ext/*"
require "../src/cavorite/utils/*"


include Cavorite::Core
include Cavorite::Utils

class TestActor < Actor(String)

  @state : Int32

  def initialize(name : String)
    super(name)
    @state = 0
  end

  def handler(msg : ActorMessage): String
    @state += 1
    result = @state.to_s
    result
  end
end

class TestMessage < UserMessage
  @text : String

  def initialize(@text : String)
    super()
  end
end