require "./actor_message"
require "./queue"
require "./strategy"

module Cavorite
  class ActorRef
  end

  enum ActorState
    Idle
    Become
    Die
  end

  abstract class Actor
    @mailbox : Queue(ActorMessage)
    @strategy : Strategy
    @handler : Proc(ActorMessage, Nil)
    @suspended : Atomic(Int32)
    @on_error : Proc(Exception, Nil)

    def initialize(&@handler : ActorMessage -> Nil)
      @mailbox = Queue(ActorMessage).new
      @strategy = Strategy.sequential
      @suspended = Atomic(Int32).new(1)

      @strategy.set(->act(Int32))
      @on_error = ->(ex : Exception){}
    end

    def send(msg : ActorMessage)
      @mailbox.enqueue(msg)
      try_schedule
    end

    # TODO: implement
    def become
    end

    # TODO: implement
    def supervise
    end

    private def try_schedule
      _, is_success = @suspended.compare_and_set(1, 0)      
      schedule if is_success
    end

    private def schedule
      @strategy.set(->act(Int32)).call
    end

    private def act(n : Int32)
      n.times do |i|
        msg = @mailbox.dequeue
        break if msg.nil?
        begin
          @handler.call(msg)
        rescue ex
          @on_error.call(ex)
        end
      end

      if @mailbox.empty?
        try_schedule
      else
        schedule
      end
    end
  end
end