require "./actor"

module Cavorite::Core
  module MainActor
    class MainActor < Actor
      def handler(msg : ActorMessage)
        ::cavorite_receive(msg)
      end
    end

    MAIN_ACTOR = MainActor.new("main_actor")

    def cavorite_send(msg : ActorMessage)
      MAIN_ACTOR.send!(msg)
    end
  end
end

include Cavorite::Core::MainActor