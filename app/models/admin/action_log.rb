# frozen_string_literal: true

class Admin
  class ActionLog < ApplicationRecord
    belongs_to :admin
    belongs_to :target, polymorphic: true

    validates :admin, :target_id, :target_type, :event, :status, presence: true

    enum status: { succeed: 0, failed: 1 }

    scope :target_space, -> { where(target_type: 'Space') }
    scope :target_order, -> { where(target_type: 'Order') }
    scope :target_payout, -> { where(target_type: 'Payout') }
    scope :target_user, -> { where(target_type: 'User') }
    scope :target_admin, -> { where(target_type: Admin::ROLES) }
    scope :target_notification, -> { where(target_type: 'Notification') }
  end
end
