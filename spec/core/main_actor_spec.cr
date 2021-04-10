require "../spec_helper"

def cavorite_receive(msg)
  case msg
  when TestMessage
    msg.text.should eq "test"
  else
    raise "failed"
  end
end

test_message = TestMessage.new("test")
cavorite_send(test_message)
