# frozen_string_literal: true

FactoryBot.define do
  factory :schedule do
    schedulable_id { 1 }
    schedulable_type { 'MyString' }
    event { 'MyString' }
    schedule_at { '2017-03-02 15:42:47' }
  end
end
