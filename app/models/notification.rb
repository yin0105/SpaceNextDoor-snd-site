# frozen_string_literal: true

class Notification < ApplicationRecord
  attr_accessor :send_to_all_user, :query_users

  # constants, unit: hour
  THRESHOLD = 1

  has_paper_trail

  belongs_to :admin
  has_many :notification_relations, dependent: :destroy, class_name: 'User::NotificationRelation'
  has_many :users, through: :notification_relations

  validates :content, presence: true

  enum notify_type: {
    all_users: 0,
    all_hosts: 1,
    hosts_with_existing_bookings: 2,
    guests_with_existing_bookings: 3,
    personal: 4
  }
end
