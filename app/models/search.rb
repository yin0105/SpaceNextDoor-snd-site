# frozen_string_literal: true

class Search < ActiveType::Object
  MIN_SEARCH_PRICE = 0
  MAX_SEARCH_PRICE = 100

  MIN_SEARCH_SIZE = 0
  MAX_SEARCH_SIZE = 100

  SORT_OPTIONS = {
    created_at_desc: { created_at: :desc },
    area_desc: { area: :desc },
    area_asc: { area: :asc },
    daily_price_cents_desc: { daily_price_cents: :desc },
    daily_price_cents_asc: { daily_price_cents: :asc }
  }.freeze

  attribute :region, :string
  attribute :price
  attribute :type
  attribute :size
  attribute :check_in
  attribute :check_out
  attribute :user_latitude
  attribute :user_longitude
  attribute :hide_map
  attribute :sort
  attribute :promotion

  def initialize(params = {})
    super

    @query = Space.all
    attributes.each { |param| with(*param) }
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  def with(param, query)
    return if query.nil?

    @query = case param.to_sym
             when :region then with_region
             when :check_in then with_date
             when :check_out then with_date
             when :price then with_price
             when :type then with_type
             when :size then with_size
             when :sort then with_sort
             when :promotion then with_promotion
             else @query
             end
  end
  # rubocop:enable Metrics/CyclomaticComplexity

  def method_missing(name, *args, &block)
    return @query.send(name, *args, &block) if @query.respond_to?(name)

    super
  end

  def respond_to_missing?(name, is_private)
    super
  end

  private

  def with_region
    return joins(:address).where(addresses: { id: Address.in(region).pluck(:id) }) if region.present?

    @query
  end

  def with_price
    where(daily_price_cents: to_range(price, ->(value) { to_cents(value) }))
  end

  def with_type
    return where(property: Space::PROPERTY[type.to_sym]) if type.present?

    @query
  end

  def with_size
    @query = where(area: to_range(size))
  end

  def with_date
    return @query unless check_in.present? || check_out.present?

    from = (check_in&.to_date rescue nil) || Time.zone.today # rubocop:disable Style/RescueModifier
    to = (check_out&.to_date rescue nil) || Float::INFINITY # rubocop:disable Style/RescueModifier

    @query = available_in(from..to)
  end

  def with_sort
    reorder(SORT_OPTIONS[sort.to_sym])
  end

  def with_promotion
    return @query = where.not(discount_code: nil) if promotion == 'true'

    @query
  end

  def to_range(range, func = nil)
    case range
    when String
      min, max = range.split('..')
      min = min.to_f
      max = max.to_f
    when Range
      min = range.min
      max = range.max
    else
      min = 0
      max = price.to_f
    end
    return (func.call(min)..func.call(max)) if func

    (min..max)
  end

  def to_cents(value)
    value.to_f.to_money.cents
  end
end
