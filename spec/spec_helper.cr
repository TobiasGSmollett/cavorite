require "spec"
require "../src/cavorite"
require "../src/cavorite/*"
require "../src/cavorite/core/*"
require "../src/cavorite/remote/*"
require "../src/cavorite/utils/*"

include Cavorite::Core
include Cavorite::Utils

class TestActor < Actor(String)
  getter state : Int32

  def initialize(name : String)
    super(name)
    @state = 0
  end

  def handler(msg : ActorMessage) : String
    @state += 1
    result = @state.to_s
    result
  end
end

class TestMessage < UserMessage
  property text : String

  def initialize(@text : String)
  end
end

TEST_CLUSTER = Cavorite::Remote::K8sCluster.new("my-service")
Cavorite::Remote::Server.new(TEST_CLUSTER).run

# spawn do
#  Cavorite::Remote::Server.new.run(8081)
# end
