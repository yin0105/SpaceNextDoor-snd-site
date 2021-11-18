# frozen_string_literal: true

class User
  class Host < ActiveType::Record[User]
    include ActiveTypeInheritable
    include User::Accounting

    scope :no_active_orders, lambda {
      joins(:orders).joins(
        "LEFT OUTER JOIN orders ON orders.host_id = users.id AND orders.status IN (#{Order::STATUS[:pending]},#{Order::STATUS[:active]})"
      ).where(orders: { host_id: nil })
    }

    has_many :orders, foreign_key: :host_id
    has_many :channels, class_name: 'Channel::Host', foreign_key: :host_id
    has_one :contact, -> { where(type: :host) }, class_name: 'Contact::Host'

    def create_ratings(order)
      ratings.create(ratable: order.guest, order: order)
    end

    def evaluations
      super.by_guest
    end
  end
end
