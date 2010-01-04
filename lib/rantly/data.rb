module Rantly::Data
  def email
    "#{string(:alnum)}@#{string(:alnum)}.#{sized(3){string(:alpha)}}".downcase
  end

  def password
    sized(8) { string(:alnum) }
  end
end

class Rantly
  include Rantly::Data
end
