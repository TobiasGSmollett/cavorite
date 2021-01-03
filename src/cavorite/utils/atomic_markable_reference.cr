require "atomic"

module Cavorite::Utils
  class AtomicMarkableReference(T)
    private class MarkableReference(T)
      def initialize(@value : T, @mark : Bool)
      end

      def unwrap
        {@value, @mark}
      end
    end

    @ref : Atomic(MarkableReference(T))

    def initialize(value : T, mark = false)
      markable_refrence = MarkableReference(T).new(value, mark)
      @ref = Atomic(MarkableReference(T)).new(markable_refrence)
    end

    def compare_and_set(expected_ref : T, new_ref : T, expected_mark : Bool, new_mark : Bool) : Tuple(Tuple(T?, Bool), Bool)
      old_ref, old_mark = @ref.get.unwrap
      if old_ref == expected_ref && old_mark == expected_mark
        new_wrapped_ref = MarkableReference(T).new(new_ref, new_mark)
        result, is_success = @ref.compare_and_set(@ref.get, new_wrapped_ref)
        return result.unwrap, is_success
      end
      return {nil, false}, false
    end

    def attempt_mark(expected_ref : T, new_mark : Bool) : Bool
      old_ref, _ = @ref.get.unwrap
      if old_ref == expected_ref
        new_wrapped_ref = MarkableReference(T).new(old_ref, new_mark)
        result, is_success = @ref.compare_and_set(@ref.get, new_wrapped_ref)
        return is_success
      end
      false
    end

    def get : Tuple(T, Bool)
      @ref.get.unwrap
    end
  end
end
