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
    @children : Array(Actor(Any, Any))

    def handler(state, message): {Nil, Nil}
      {nil, nil}
    end

    def initialize(@strategy : Strategy)
      super(nil)
      @children = [] of Actor(Any, Any)
    end

    def add_child(child : Actor(S, R)) forall S, R
      child.supervisor_on_error = ->(ex : Exception){ reset(@children.size) }
      @children << child.as(Actor(Any, Any))
    end

    def reset(error_child_index : Int32)
      restart_message = Restart.new
      case @strategy
      when Strategy::OneForOne
        @children[error_child_index].send(restart_message)
      when Strategy::OneForAll
        @children.each { |child| child.send(restart_message) }
      when Strategy::RestForOne
        (error_child_index..(@children.size - 1)).each do |i| 
          @children[i].send(restart_message)
        end
      end
    end
  end
end