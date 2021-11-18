# frozen_string_literal: true

module OrderErrorHandler
  extend ActiveSupport::Concern

  included do
    rescue_from CreateOrderForm::MinimumRentDaysError do
      redirect_to space_path(@form.order.space), flash: { error: @form.order.errors[:days].first }
    end

    rescue_from CreateOrderForm::DiscountOneMonthRequireDaysError do
      redirect_to space_path(@form.order.space), flash: {
        error: I18n.t('activerecord.errors.models.order.attributes.discount_code.not_over_one_month_needed_days')
      }
    end

    rescue_from CreateOrderForm::DiscountTwoMonthsRequireDaysError do
      redirect_to space_path(@form.order.space), flash: {
        error: I18n.t('activerecord.errors.models.order.attributes.discount_code.not_over_two_months_needed_days')
      }
    end
  end
end
