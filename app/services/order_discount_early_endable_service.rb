# frozen_string_literal: true

class OrderDiscountEarlyEndableService
  def initialize(order, params)
    @order = order
    @params = params
  end

  def endable?
    return true unless @order.discounted?

    case @order.discount_code
    when 'one_month'
      (@params[:early_check_out].to_date - @order.start_at).ceil >= Order::DISCOUNT_ONE_MONTH_DAYS
    when 'two_months'
      (@params[:early_check_out].to_date - @order.start_at).ceil >= Order::DISCOUNT_TWO_MONTHS_DAYS
    when 'six_months'
      (@params[:early_check_out].to_date - @order.start_at).ceil >= Order::DISCOUNT_SIX_MONTHS_DAYS
    else
      false
    end
  end

  def begin_of_endable_date
    case @order.discount_code
    when 'one_month'
      (@order.start_at + Order::DISCOUNT_ONE_MONTH_DAYS)
    when 'two_months'
      (@order.start_at + Order::DISCOUNT_TWO_MONTHS_DAYS)
    when 'six_months'
      (@order.start_at + Order::DISCOUNT_SIX_MONTHS_DAYS)
    end
  end
end
