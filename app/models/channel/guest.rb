# frozen_string_literal: true

class Channel
  class Guest < ActiveType::Record[Channel]
    def target
      host
    end
  end
end
