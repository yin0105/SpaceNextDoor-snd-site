# frozen_string_literal: true

class Channel
  class Host < ActiveType::Record[Channel]
    def target
      guest
    end
  end
end
