# frozen_string_literal: true

# if you need to create an order with payment,
# please user DirectOrder instead of Order
class DirectOrder < ActiveType::Record[Order]
  attribute :term, :boolean

  include ActiveTypeInheritable

  # validations
  validates :start_at, :end_at, :term, presence: true
  validate :validate_start_at_and_end_at
  validate :validate_dates_range
  validate :validate_minimum_rent_days
  validate :validate_identity
  validate :validate_payment_method
  validate :validate_phone_number

  private

  def validate_payment_method
    return unless guest && guest.payment_method.nil?

    errors.add(:guest, :no_payment_method)
  end

  def validate_phone_number
    return unless guest && guest.phone.nil?

    errors.add(:guest, :no_phone)
  end

  def validate_start_at_and_end_at
    return if errors.any?

    errors.add(:start_at, 'start_at must be earlier than end_at.') unless start_at < end_at
    errors.add(:start_at, 'You may only book this space up to 30 days in advance. Please select another check in date.') unless validate_one_month_dates
  end

  # order's time range between start_at and end_at must be included in space's dates
  def validate_dates_range
    return if errors.any?

    errors.add(:days, :selected_dates_must_be_within_space_activated_dates) unless validate_dates(space.dates)
    errors.add(:days, :selected_dates_must_be_within_space_available_dates) unless validate_dates(space.available_dates)
  end

  def validate_minimum_rent_days
    return if errors.any? || long_lease?

    min = space.minimum_rent_days
    min_days_label = SpaceOption.minimum_rent_days(:storage, true).fetch(min, '').downcase
    errors.add(:days, :no_enough_days, days: min_days_label) if days < min
  end

  def validate_dates(dates)
    booking_dates = [*start_at..end_at]
    (dates - booking_dates).count + days == dates.count
  end

  def validate_identity
    return if host.id != guest.id

    errors.add(:guest, :host_cannot_order_his_own_space)
  end

  def validate_one_month_dates
    start_at.in?(Time.zone.today..Time.zone.today + 29)
  end
end
