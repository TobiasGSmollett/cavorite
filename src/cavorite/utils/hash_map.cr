module Cavorite::Utils
  class HashMap(K, V)

    def initialize
      @mutex = Mutex.new
      @hash = {} of K => V
    end

    def []=(key : K, value : V)
      @mutex.synchronize do
        @hash[key] = value
      end
    end

    def [](key : K)
      @mutex.lock
      result = @hash[key]
      @mutex.unlock
      result
    end
  end
end