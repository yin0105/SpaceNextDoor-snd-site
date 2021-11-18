# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

user = FactoryBot.create(:user, :with_payment_method, :with_bank_account, email: 'example@example.com', password: '1234567890')

storage = FactoryBot.create(:storage, :activated, user: user)
storages = FactoryBot.create_list(:storage, 5, :activated)

order = FactoryBot.create(:order, :with_payments, host: user.as_host, space: storage.space)
FactoryBot.create(:order, :with_payments, :completed, guest: user.as_guest, space: storages.first.space)

%i[guest host space].each do |target|
  FactoryBot.create_list(:rating, 25, :completed, order: order, target: target)
end

storages.each do |s|
  FactoryBot.create(:favorite_space_relation, user: user, space: s.space)
end
