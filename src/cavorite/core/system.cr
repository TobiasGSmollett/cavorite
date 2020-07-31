require "./supervisor"

module Cavorite::Core
  class System
    @@systems = {} of String => System

    @root_guardian : Supervisor
    @user_guardian : Supervisor
    @system_guardian : Supervisor

    def initialize(@name : String)
      @root_guardian = Supervisor.new("root_guardian", Supervisor::Strategy::OneForOne)
      @user_guardian = Supervisor.new("user_guardian", Supervisor::Strategy::OneForOne)
      @system_guardian = Supervisor.new("system_guardian", Supervisor::Strategy::OneForOne)
      @@systems[@name] = self
    end

    def add(actor : ActorMarker)
      @user_guardian.add_child(actor)
    end

    def send!(actor_ref : ActorRef, msg : UserMessage)
      get(actor_ref).send!(msg)
    end

    def send(actor_ref : ActorRef, msg : UserMessage)
      actor = get(actor_ref)
      return nil if actor.nil?
      actor.send(msg)
    end

    def get(actor_ref : ActorRef)
      result = @user_guardian
      # TODO: validate actor_ref.path
      actor_ref.path.split('/').each do |child_name|
        return nil if !result.is_a?(Supervisor)
        result = result.children[child_name]?
      end
      return nil if result.nil?
      result
    end
  end
end