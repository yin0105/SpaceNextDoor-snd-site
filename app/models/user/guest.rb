# frozen_string_literal: true

class User
  class Guest < ActiveType::Record[User]
    include ActiveTypeInheritable
    include User::Accounting

    scope :no_active_orders, lambda {
      joins(:orders).joins(
        "LEFT OUTER JOIN orders ON orders.guest_id = users.id AND orders.status IN (#{Order::STATUS[:pending]},#{Order::STATUS[:active]})"
      ).where(orders: { guest_id: nil })
    }

    has_many :orders, foreign_key: :guest_id
    has_many :payments, foreign_key: :user_id
    has_many :direct_orders, foreign_key: :guest_id
    has_many :channels, class_name: 'Channel::Guest', foreign_key: :guest_id
    has_one :contact, -> { where(type: :guest) }, class_name: 'Contact::Guest'

    def create_ratings(order)
      ratings.create(ratable: order.space, order: order)
      ratings.create(ratable: order.host, order: order)
    end

    def evaluations
      super.by_host
    end
  end
end
