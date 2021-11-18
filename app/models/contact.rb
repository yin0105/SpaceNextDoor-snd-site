# frozen_string_literal: true

class Contact < ApplicationRecord
  self.inheritance_column = :_type

  belongs_to :user

  TYPES = {
    host: 0,
    guest: 1
  }.freeze

  enum type: TYPES

  validates :name, :type, :phone, :email, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, phone: true
end
