require "../utils/queue"

module Cavorite::Core
  class Mailbox
    include Cavorite::Utils

    @@dead_letters : Queue(UserMessage) = Queue(UserMessage).new

    @system_messages : Queue(SystemMessage)
    @user_messages : Queue(UserMessage)

    def move_to_dead_letters
      # TODO: implement fast merge
      until @user_messages.empty?
        user_message = @user_messages.dequeue
        @@dead_letters.enqueue(user_message) if !user_message.nil?
      end
    end

    def initialize
      @system_messages = Queue(SystemMessage).new
      @user_messages = Queue(UserMessage).new
    end

    def empty?
      @system_messages.empty? && @user_messages.empty?
    end

    def post(actor_message : ActorMessage)
      if actor_message.is_a?(SystemMessage)
        @system_messages.enqueue(actor_message)
      elsif actor_message.is_a?(UserMessage)
        @user_messages.enqueue(actor_message)
      else
        raise "you find bug"
      end
    end

    def dequeue_system_message: SystemMessage?
      @system_messages.dequeue
    end

    def dequeue_user_message: UserMessage?
      @user_messages.dequeue
    end
  end
end