module Cavorite::Utils
  class List(T)
    private class Node(T)
      @item : T?
      @key : UInt64

      getter next : AtomicMarkableReference(Node(T)?)

      def initialize(@item : T)
        @key = @item.hash
        @next = AtomicMarkableReference(Node(T)?).new(nil)
      end

      def initialize(@key : UInt64)
        @item = nil
        @next = AtomicMarkableReference(Node(T)?).new(nil.as(Node(T)?))
      end
    end

    class Window(T)
      property pred : Node(T)
      property curr : Node(T)

      def initialize(@pred : Node, @curr : Node)
      end
    end

    @head : Node(T)?

    def initialize
      @head  = Node(T).new(UInt64::MIN)
      tail = Node(T).new(UInt64::MAX)
      loop do
        result, is_success = @head.as(Node(T)).next.compare_and_set(nil, tail, false, false)
        break if is_success
      end
    end

    def find(head : Node, key : UInt64): Window(T)
      pred : Node(T)? = nil
      curr : Node(T)? = nil
      succ : Node(T)? = nil
      marked = [false]
      snip = false

      #retry: while (true) {
      #  pred = head;
      #  curr = pred.next.getReference();
      #  while (true) {
      #    succ = curr.next.get(marked); 
      #    while (marked[0]) {           
      #      snip = pred.next.compareAndSet(curr, succ, false, false);
      #      if (!snip) continue retry;
      #      curr = pred.next.getReference();
      #      succ = curr.next.get(marked);
      #    }
      #    if (curr.key >= key)
      #      return new Window(pred, curr);
      #    pred = curr;
      #    curr = succ;
      #  }
      #}
    end



  end
end