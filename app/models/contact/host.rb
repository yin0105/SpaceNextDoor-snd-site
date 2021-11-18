# frozen_string_literal: true

class Contact
  class Host < ActiveType::Record[Contact]
    belongs_to :host, class_name: 'User::Host', foreign_key: 'user_id', optional: true
  end
end
