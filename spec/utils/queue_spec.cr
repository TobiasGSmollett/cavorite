require "../spec_helper"

describe Cavorite do

  it "single thread" do

    input = [1, 2, 3, 4, 5]
    output = [] of Int32

    queue = Queue(Int32).new

    input.each { |e| queue.enqueue(e) }
    until queue.empty?
      output << queue.dequeue.as(Int32)
    end
    input.should eq(output)
  end

  it "enqueue on multi thread" do
    input = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    wait_group = Array(Channel(Nil)).new(10, Channel(Nil).new)

    queue = Queue(Int32).new

    (1..10).each do |i|
      spawn do
        input.each { |e| queue.enqueue(e) }
        wait_group[i-1].send(nil)
      end
    end

    (0..9).each do |i|
      wait_group[i].receive
    end

    sum = 0
    until queue.empty?
      sum += queue.dequeue.as(Int32)
    end
    sum.should eq(550)
  end
end