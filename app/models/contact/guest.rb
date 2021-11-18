# frozen_string_literal: true

class Contact
  class Guest < ActiveType::Record[Contact]
    belongs_to :guest, class_name: 'User::Guest', foreign_key: 'user_id', optional: true
  end
end
