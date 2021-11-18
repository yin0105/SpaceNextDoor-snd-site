# frozen_string_literal: true

module PriceHelper
  def calculate_price_in_days(space, days)
    (space.daily_price * days).format
  end

  def calculate_guest_service_fee(space, days)
    (space.daily_price * days * Settings.service_fee.guest_rate).format
  end

  def calculate_deposit(space)
    (space.daily_price * Settings.deposit.days).format
  end

  def calculate_total(space, **arg)
    days = arg[:order]&.days || 1
    premium = arg[:order]&.premium

    total_rate = days * (1 + Settings.service_fee.guest_rate) + Settings.deposit.days

    total_price = space.daily_price * total_rate

    return total_price.format unless space.insurance_enable?

    (total_price + calculate_premium(days, premium: premium)).format
  end

  def calculate_premium(days, **arg)
    premium = arg[:premium] || Money.new(Insurance.premium())
    months_amount = (days.to_f / 30.0).ceil
    months_amount * premium
  end

  def calculate_long_lease_total(space, order)
    return (order.monthly_total - (order.space.daily_price * Order::INTERVAL / 2)).format if order.six_months_discount_code?
    return (space.daily_price * Settings.deposit.days + order.premium).format if order.discounted?

    order.monthly_total.format
  end

  def calculate_discount(order)
    service_fee = (order.space.daily_price * Order::INTERVAL * Settings.service_fee.guest_rate)
    rent = order.space.daily_price * Order::INTERVAL
    rent /= 2 if order.six_months_discount_code?
    "−#{(service_fee + rent).format}"
  end
end
