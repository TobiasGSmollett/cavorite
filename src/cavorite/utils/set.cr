module Cavorite::Utils
  class Set(T)

    def initialize
      @mutex = Mutex.new
      @set = ::Set(T).new
    end

    def get
      @mutex.lock
      result = @set.dup
      @mutex.unlock
      result
    end

    def add(value : T)
      @mutex.synchronize { @set << value }
    end

    def delete(value : T)
      @mutex.synchronize { @set.delete(value) }
    end

    def each(&block : T -> Nil)
      @mutex.synchronize { @set.each &block }
    end

    def clear
      @mutex.synchronize { @set.clear }
    end
  end
end