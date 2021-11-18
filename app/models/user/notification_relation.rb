# frozen_string_literal: true

class User
  class NotificationRelation < ApplicationRecord
    belongs_to :user
    belongs_to :notification
  end
end
