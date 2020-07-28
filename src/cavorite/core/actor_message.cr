module Cavorite::Core
  abstract class ActorMessage
    @is_required_response : Bool = false

    property is_required_response : Bool
  end

  class SystemMessage < ActorMessage
  end

  class Die < SystemMessage
  end

  class Restart < SystemMessage
  end

  class UserMessage < ActorMessage
  end
end