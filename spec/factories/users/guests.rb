# frozen_string_literal: true

FactoryBot.define do
  factory :guest, class: 'User::Guest', parent: :user do
  end
end
