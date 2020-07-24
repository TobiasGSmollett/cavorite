require "./spec_helper"

include Cavorite

describe Cavorite do

  it "works" do

    input = [1, 2, 3, 4, 5]

    queue = Queue(Int32).new

    input.each { |e| queue.enqueue e }
    output = [] of Int32
    until queue.empty?
      tmp = queue.dequeue
      output << tmp if !tmp.nil?
    end
    input.should eq(output)
  end
end