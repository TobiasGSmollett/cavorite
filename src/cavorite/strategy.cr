require "./actor_message"

module Cavorite

  module Strategy
    def self.sequential
      Sequential.new
    end
  end

  class Sequential
    include Strategy

    @act : Proc(Int32, Nil)

    def initialize
      @act = ->(i : Int32){}
    end

    def set(act : Int32 -> Nil)
      @act = act
      self
    end

    def call(i : Int32 = 1024)
      @act.call(i)
    end
  end
end