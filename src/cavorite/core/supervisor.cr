require "./actor"
require "../ext/any"

module Cavorite::Core
  class Supervisor < Actor(Nil, Nil)
    enum Strategy
      OneForOne
      OneForAll
      RestForOne
    end

    @strategy : Strategy
    # TODO: use radix tree
    @children : Hash(String, Actor(Any, Any))

    getter children : Hash(String, Actor(Any, Any))

    def initialize(name : String, @strategy : Strategy)
      super(name)
      @children = {} of String => Actor(Any, Any)
    end

    def add_child(child : Actor(S, R)) forall S, R
      child.supervisor_on_error = ->(ex : Exception){ reset(child.name) }
      @children[child.name] = child.as(Actor(Any, Any))
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