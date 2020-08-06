require "msgpack"

require "./actor"
require "../ext/any"

module Cavorite::Core
  class Supervisor < Actor(Nil)
    include ActorMarker

    enum Strategy
      OneForOne
      OneForAll
      RestForOne
    end

    @strategy : Strategy
    # TODO: use radix tree
    @children : Hash(String, ActorMarker)

    getter children : Hash(String, ActorMarker)

    def initialize(name : String, @strategy : Strategy)
      super(name)
      @children = {} of String => ActorMarker
    end

    def initialize(name : String, @strategy : Strategy, children : Array(ActorMarker))
      super(name)
      @children = {} of String => ActorMarker
      children.each { |child| @children[child.name] = child }
    end

    def add_child(child : ActorMarker)
      child.supervisor_on_error = ->(ex : Exception){ reset(child.name) }
      @children[child.name] = child
    end

    private def reset(error_child_index : String)
      restart_message = Restart.new
      case @strategy
      when Strategy::OneForOne
        @children[error_child_index].send(restart_message)
      when Strategy::OneForAll
        @children.each { |name, child| child.send(restart_message) }
      when Strategy::RestForOne
        raise "unimplemented"
      end
    end

    private def handler(message): Nil
    end
  end
end