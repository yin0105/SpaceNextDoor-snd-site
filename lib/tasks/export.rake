# frozen_string_literal: true

SPACES_ATTRIBUTES = %i[id name description address_area area features facilities daily_price minimum_rent_days orders_count].freeze

ORDERS_ATTRIBUTES = %i[space_id start_at end_at price_cents].freeze

namespace :export do
  desc 'Export spaces data'
  task spaces: :environment do
    add_aliases_to_space

    puts(CSV.generate(headers: true) do |csv|
      csv << SPACES_ATTRIBUTES
      Space.all.each { |space| csv << SPACES_ATTRIBUTES.map { |attr| space.send(attr) } }
    end)
  end

  desc 'Export bookings data'
  task bookings: :environment do
    puts(CSV.generate(headers: true) do |csv|
      csv << ORDERS_ATTRIBUTES
      Order.all.each { |order| csv << ORDERS_ATTRIBUTES.map { |attr| order.send(attr) } }
    end)
  end
end

def add_aliases_to_space
  Space.send(:define_method, :orders_count) do
    orders.count
  end

  Space.send(:define_method, :address_area) do
    address.area
  end

  Space.send(:define_method, :features) do
    spaceable.features.join(',')
  end

  Space.send(:define_method, :facilities) do
    spaceable.facilities.join(',')
  end
end
