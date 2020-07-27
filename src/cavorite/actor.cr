require "./actor_message"
require "./mailbox"
require "./scheduler"

module Cavorite
  class ActorRef
  end

  enum ActorState
    Idle
    Occupied
    Stopped
  end

  # R is response type
  abstract class Actor(R)    
    @mailbox : Mailbox
    @scheduler : Scheduler
    @handler : Proc(ActorMessage, R)
    @interlocked : Atomic(ActorState)
    @on_error : Proc(Exception, Nil)
    
    @response_channel : Channel(R)

    def initialize(&@handler : ActorMessage -> R)
      @mailbox = Mailbox.new
      @scheduler = Scheduler.naive
      @interlocked = Atomic(ActorState).new(ActorState::Idle)

      @scheduler.set(->act(Int32))
      @on_error = ->(ex : Exception){}

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

    def stop
      @interlocked.set(ActorState::Stopped)
    end

    def reset
      @mailbox.move_to_dead_letters
      @interlocked.set(ActorState::Idle)
    end

    # TODO: implement
    def become
    end

    private def try_schedule
      _, is_success = @interlocked.compare_and_set(ActorState::Idle, ActorState::Occupied)
      schedule if is_success
    end

    private def schedule
      @scheduler.set(->act(Int32)).call
    end

    private def act(n : Int32): Nil
      n.times do |i|
        break if @mailbox.empty?

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
        result = @handler.call(user_message)
        @response_channel.send(result)
      rescue ex
        @interlocked.set(ActorState::Idle)
        @on_error.call(ex)
      end
    end
  end
end