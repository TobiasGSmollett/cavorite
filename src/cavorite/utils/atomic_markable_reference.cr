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
    
    def compare_and_set(expected_reference : T, new_reference : T, expected_mark : Bool, new_mark : Bool): Tuple(T?, Bool)
      old_wrapped_reference = @ref.get
      old_ref, old_mark = old_wrapped_reference.unwrap

      if old_ref == expected_reference && old_mark == expected_mark
        new_wrapped_ref = MarkableReference(T).new(new_reference, new_mark)
        result, is_success = @ref.compare_and_set(old_wrapped_reference, new_wrapped_ref)
        return result.unwrap if is_success
      end
      return nil, false
    end
    
    def attempt_mark(expected_reference : T, new_mark : Bool): Bool
      old_wrapped_reference = @ref.get
      old_ref, _ = old_wrapped_reference.unwrap

      if old_ref == expected_reference
        new_wrapped_ref = MarkableReference(T).new(old_ref, new_mark)
        result, is_success = @ref.compare_and_set(old_wrapped_reference, new_wrapped_ref)
        return is_success
      end
      false
    end
    
    def get: Tuple(T, Bool)
      @ref.get.unwrap
    end
  end
end