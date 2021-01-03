require "./atomic_markable_reference"

module Cavorite::Utils
  class List(T)
    private class Node(T)
      getter item : T?
      getter key : UInt64
      property next : AtomicMarkableReference(Node(T)?)

      def initialize(@item : T)
        @key = @item.hash
        @next = AtomicMarkableReference(Node(T)?).new(nil.as(Node(T)?))
      end

      def initialize(@key : UInt64)
        @item = nil
        @next = AtomicMarkableReference(Node(T)?).new(nil.as(Node(T)?))
      end
    end

    class Window(T)
      property pred : Node(T)
      property curr : Node(T)

      def initialize(@pred : Node(T), @curr : Node(T))
      end
    end

    @head : Node(T)

    def initialize
      @head  = Node(T).new(UInt64::MIN)
      tail = Node(T).new(UInt64::MAX)
      loop do
        result, is_success = @head.as(Node(T)).next.compare_and_set(nil, tail, false, false)
        break if is_success
      end
    end


    def add(item : T): Bool
      key = item.hash
      loop do
        window : Window(T) = find(@head, key)
        pred : Node(T) = window.pred
        curr : Node(T) = window.curr
        if curr.key == key
          return false
        else
          node = Node(T).new(item)
          node.next = AtomicMarkableReference(Node(T)?).new(curr.as(Node(T)?))
          succ, _ = pred.next.compare_and_set(curr, node, false, false)
          return true if succ
        end
      end
    end

    def remove(item : T): Bool
      key = item.hash
      snip : Bool = false
      loop do
        window : Window(T) = find(@head, key)
        pred : Node(T) = window.pred
        curr : Node(T) = window.curr
        if curr.key != key
          return false
        else
          succ, _ = curr.next.get
          snip = curr.next.attempt_mark(succ, true)
          next if !snip
          pred.next.compare_and_set(curr, succ, false, false)
          return true
        end
      end
    end

    def contains(item : T): Bool
      key = item.hash
      window: Window(T) = find(@head, key)
      pred: Node(T) = window.pred
      curr: Node(T) = window.curr
      curr.key == key
    end

    def find(head : Node, key : UInt64): Window(T)
      pred : Node(T)? = nil
      curr : Node(T)? = nil
      succ : Node(T)? = nil
      snip = false

      loop do
        pred = head
        curr, _mark = pred.next.get
        loop do
          succ, marked = curr.as(Node(T)).next.get
          flag = false
          while marked
            snip = pred.as(Node(T)).next.compare_and_set(curr, succ, false, false)
            unless snip
              flag = true
              break
            end
            curr, _ = pred.as(Node(T)).next.get
            succ, marked = curr.as(Node(T)).next.get
          end
          break if flag
          return Window(T).new(pred.as(Node(T)), curr.as(Node(T))) if curr.as(Node(T)).key >= key
          pred = curr
          curr = succ
        end
      end
    end



  end
end