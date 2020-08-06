require "uri"

class HTTP::Request
  def uri
    (@uri ||= URI.parse(@resource)).not_nil!
  end
end