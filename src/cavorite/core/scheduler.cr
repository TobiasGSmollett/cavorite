
module Cavorite::Core

  module Scheduler
    @act : Proc(Int32, Nil)

    def initialize
      @act = ->(i : Int32){}
    end

    def set(@act : Int32 -> Nil)
      self
    end

    abstract def call(i : Int32 = 1024) : Nil

    # Processes all the actors messages sequentially in a single-thread.
    def self.sequential
      Sequential.new
    end

    # Spawns a new thread for every evaluation.
    def self.naive
      Naive.new
    end
  end

  class Sequential
    include Scheduler

    def call(i : Int32 = 1024)
      @act.call(i)
    end
  end

  class Naive
    include Scheduler

    def call(i : Int32 = 1024)
      spawn { @act.call(i) }
    end
  end
end