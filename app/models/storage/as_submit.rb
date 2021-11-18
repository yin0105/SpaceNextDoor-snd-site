# frozen_string_literal: true

class Storage
  class AsSubmit < ActiveType::Record[Form]
    before_validation do |record|
      record.space.submit if record.space.may_submit?
    end
  end
end
