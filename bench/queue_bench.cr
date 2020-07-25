require "./bench_helper"

N = 100 # Number of Thread
M = 100000 # Number of Operation

Benchmark.bm do |job|
  job.report "push/shift of Deque(T) on ST" do
    deque = Deque(Int32).new
    M.times { |i| deque << i }
    M.times { |i| deque.shift }
  end

  job.report "enqueue/dequeue on ST" do
    queue = Queue(Int32).new
    M.times { |i| queue.enqueue(i) }
    M.times { |i| queue.dequeue }
  end

  job.report "push/shift of Deque(T) and Mutex on MT" do
    deque = Deque(Int32).new
    mutex = Thread::Mutex.new
    channels = Array(Channel(Nil)).new(N * 2, Channel(Nil).new)
  
    N.times do |i|
      spawn do
        M.times { mutex.synchronize { deque << 0 } }
        channels[i].send(nil)
      end
    end
  
    N.times do |i|
      spawn do
        M.times { mutex.synchronize { deque.shift } }
        channels[N + i].send(nil)
      end
    end

    (N * 2).times { |i| channels[i].receive }
  end

  job.report "enqueue/dequeue on MT" do
    queue = Queue(Int32).new
    channels = Array(Channel(Nil)).new(N * 2, Channel(Nil).new)

    N.times do |i|
      spawn do
        M.times { queue.enqueue(0) }
        channels[i].send(nil)
      end
    end
  
    N.times do |i|
      spawn do
        M.times { queue.dequeue }
        channels[N + i].send(nil)
      end
    end

    (N * 2).times { |i| channels[i].receive }
  end
end