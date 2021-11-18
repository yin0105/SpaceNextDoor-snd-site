# frozen_string_literal: true

class Admin < ApplicationRecord
  ROLES = %w[Admin::General Admin::Root].freeze

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable,
         :lockable

  has_paper_trail

  has_many :notifications, dependent: :destroy
  has_many :admin_action_logs, class_name: 'Admin::ActionLog', dependent: :destroy

  def name
    email.split('@').first
  end
end
