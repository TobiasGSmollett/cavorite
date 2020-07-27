require "./actor"
require "./ext"

module Cavorite
  class Supervisor < Actor(Nil)
    enum Strategy
      OneForOne
      OneForAll
      RestForOne
    end

    @strategy : Strategy
    @children : Array(Actor(Any))

    def initialize(@strategy : Strategy)
      super()
      @children = [] of Actor(Any)
    end

    def add_child(child : Actor(T)) forall T
      @children << child.as(Actor(Any))
    end

    # TODO: move to actor class
    def resume
    end

    # TODO: move to actor class
    def restart
    end
  end
end