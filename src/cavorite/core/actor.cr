require "./actor_message"
require "./mailbox"
require "./scheduler"

module Cavorite::Core
  enum ActorState
    Idle
    Occupied
    Stopped
  end

  module ActorMarker
  end

  # S : type of state
  # R : type of response
  abstract class Actor(S, R)
    include ActorMarker
    
    @name : String
    @mailbox : Mailbox
    @scheduler : Scheduler
    @interlocked : Atomic(ActorState)
    @on_error : Proc(Exception, Nil)
    
    @supervisor_on_error : Proc(Exception, Nil)
    @response_channel : Channel(R)

    getter name : String
    setter supervisor_on_error : Proc(Exception, Nil)

    abstract def handler(msg : ActorMessage): R

    def initialize(@name : String)
      @mailbox = Mailbox.new
      @scheduler = Scheduler.naive
      @interlocked = Atomic(ActorState).new(ActorState::Idle)

      @scheduler.set(->act(Int32))
      @on_error = ->(ex : Exception){}

      @supervisor_on_error = ->(ex : Exception){}
      @response_channel = Channel(R).new
    end

    def send(msg : ActorMessage)
      msg.is_required_response = true
      @mailbox.post(msg)
      try_schedule
      @response_channel
    end

    def send!(msg : ActorMessage)
      @mailbox.post(msg)
      try_schedule
    end

    private def stop
      @interlocked.set(ActorState::Stopped)
    end

    private def reset
      @mailbox.move_to_dead_letters
      @interlocked.set(ActorState::Idle)
    end

    private def try_schedule
      _, is_success = @interlocked.compare_and_set(ActorState::Idle, ActorState::Occupied)
      schedule if is_success
    end

    private def schedule
      @interlocked.set(ActorState::Occupied)
      @scheduler.set(->act(Int32)).call
    end

    private def act(n : Int32): Nil
      n.times do |i|
        if @mailbox.empty?
          @interlocked.set(ActorState::Idle)
          break
        end

        system_message = @mailbox.dequeue_system_message
        unless system_message.nil?
          handle_system_message(system_message)
        else
          user_message = @mailbox.dequeue_user_message
          break if user_message.nil?
          handle_user_message(user_message)
        end
      end

      if @mailbox.empty?
        try_schedule
      else
        schedule
      end
    end

    private def handle_system_message(system_message : SystemMessage)
      case system_message
      when Die
        stop
      when Restart
        reset
      end
    end

    private def handle_user_message(user_message : UserMessage)
      begin
        result = handler(user_message)
        @response_channel.send(result) if user_message.is_required_response
      rescue ex
        @interlocked.set(ActorState::Idle)
        @on_error.call(ex)
        @supervisor_on_error.call(ex)
      end
    end
  end
end