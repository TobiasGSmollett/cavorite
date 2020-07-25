require "./spec_helper"

class TestActor < Actor
end

class TestMessage
  include ActorMessage

  getter text : String

  def initialize(@text : String)  
  end
end

describe Cavorite do
  it "create actor" do
    actor = TestActor.new do |msg|
      puts msg.text
    end

    actor.send(TestMessage.new("test"))
  end
end