# frozen_string_literal: true

module OrdersHelper
  # TODO: Refactor to shared with channel
  def render_order_navigation
    content_tag :ul do
      capture do
        %i[guest host].each { |type| concat render_order_navigation_item(type) }
      end
    end
  end

  def render_order_navigation_item(type)
    style = ['order-index__navigation d-inline-block p-3']
    style << 'active' if current_order_page?(type)
    content_tag :li, class: style.join(' ') do
      link_to t("roles.#{type}"), orders_path(identity: type), class: 'text-gray-deep'
    end
  end

  def current_order_page?(type)
    current_page?(orders_path) && params.fetch(:identity, :guest).to_sym == type
  end

  def guest_tab?
    params.fetch(:identity, :guest).to_sym == :guest
  end

  def render_order_details_button(order)
    type = guest_tab? ? 'guest' : 'host'
    link_to 'Details', order_path(order, identity: type), class: 'list-panel__button bg-orange'
  end

  def render_cancel_renewal_button(order)
    return if params[:identity] == 'host'
    return unless order.long_term_cancellable?

    link_to 'Cancel Renewal', cancel_long_lease_order_path(order), class: 'list-panel__button bg-yellow-deep'
  end

  def render_insurance_buttons(order)
    return if params[:identity] == 'host'
    return unless order.insurance_enable && order.can_change_insurance?

    capture do
      concat link_to t('.insurance_options'), edit_insurance_order_path(order), class: 'list-panel__button bg-blue-deep js-insurance-options-button'
    end
  end

  def render_transform_long_lease_buttons(order)
    return if params[:identity] == 'host'
    return unless order.transformable_long_term?

    capture do
      concat link_to t('.transform_long_lease'), edit_transform_long_lease_order_path(order), class: 'list-panel__button bg-yellow-deep'
    end
  end

  def current_insurance_type(order)
    return order.insurance_type if order.pending?

    order.last_payment&.insurance_type || Insurance::NULL_INSURANCE_TYPE
  end

  def display_insurance(type)
    I18n.t("insurance.#{type}.insurance")
  end

  def render_renewal_insurance(order)
    style = ['text-left js-display-block']
    style << 'hidden' if order.insurance_type == current_insurance_type(order)

    capture do
      content_tag :p, class: style do
        concat '('
        concat content_tag(:span, display_insurance(order.insurance_type), id: 'js-preview-block')
        concat " is w.e.f. #{display_next_service_start_date(order)})"
      end
    end
  end

  def display_next_service_start_date(order)
    I18n.l(order.next_service_start_at.to_date, format: :date_inverse)
  end

  def render_order_or_payment_status(order)
    status_color(order.pending? ? Payment.new : order)
  end

  def calculate_order_deposit(order)
    order.deposit || order.price * Settings.deposit.days
  end

  def render_initial_payment_amount(order)
    InitializePaymentService.new(order).start!.amount.format
  end

  def render_initial_payment_action(order)
    return unless order.pending?

    link_to 'Pay', order_payments_path(order), class: 'button bg-gray-deep', data: { method: :post }
  end

  def render_pay_button(user, form)
    return fake_pay_button unless user.can_book?

    form.submit 'Pay',
                class: 'button button-secondary button-full-width'
  end

  def fake_pay_button
    link_to 'Pay', '#cannot-book-modal', class: 'button button-secondary button-full-width', data: { toggle: 'modal' }
  end

  def render_cannot_book_modal
    return unless current_user
    return if current_user.can_book?

    render '/shared/cannot_book_modal'
  end

  def render_cannot_promotion_modal(form)
    return if !form.order.discounted? || form.promotion_avaliable?

    min_days = Order.const_get("Order::DISCOUNT_REQUIRED_DAYS_#{Order.discount_codes.key(form.discount_code).upcase}")
    render partial: '/shared/cannot_promotion_modal', locals: { min_days: min_days }
  end

  def auto_renewal_terms(order)
    content_tag :span, t('.long_lease_terms') if order.long_lease?
  end

  def long_term_days
    "#{Order::INTERVAL} days"
  end

  def lease_differentiator(order, long_term, short_term)
    order.long_lease? ? long_term : short_term
  end

  def enabled_checkout_dates(order)
    return enabled_dates(discount_cancelable_date(order)) if order.discounted?
    return enabled_dates(order.start_at + min_notice_days(order)) unless order.started?

    enabled_dates(enabled_cancelling_start_at(order))
  end

  def long_term_end_at_label(order)
    'Paid through date' if order.long_lease?
  end

  private

  def enabled_dates(start_date)
    (start_date...start_date + Order::LONGEST_YEAR.years).map(&:to_s).join(';')
  end

  def min_notice_days(order)
    return order.min_rent_days - 1.day if order.min_rent_days > 7.days

    order.notice_days
  end

  def enabled_cancelling_start_at(order)
    min_rent_fulfilled_date = order.start_at + order.min_rent_days - 1.day
    days_to_fulfilled_date = min_rent_fulfilled_date - Time.zone.today

    return order.start_at + min_notice_days(order) unless order.started?
    return order.long_term_start_at if order.long_term_start_at.present? && order.long_term_start_at >= (Time.zone.today + order.notice_days)
    return Time.zone.today + order.notice_days unless order.min_rent_days > 7.days

    days_to_fulfilled_date.days > order.notice_days ? min_rent_fulfilled_date : Time.zone.today + order.notice_days
  end

  def display_cancelling_date(order)
    return discount_cancelable_date(order) if order.discounted?

    enabled_cancelling_start_at(order)
  end

  def discount_cancelable_date(order)
    Time.zone.today < (discount_minimum_end_at(order) - order.notice_days) ? discount_minimum_end_at(order) : Time.zone.today + order.notice_days
  end

  def discount_minimum_end_at(order)
    return order.start_at + Order::DISCOUNT_ONE_MONTH_DAYS.days if order.discount_code == 'one_month'

    order.start_at + Order::DISCOUNT_TWO_MONTHS_DAYS.days
  end

  def render_order_discount_options(order)
    return unless order.discounted?

    render partial: "discount_#{order.discount_code}_options"
  end
end
