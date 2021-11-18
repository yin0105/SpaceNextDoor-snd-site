# frozen_string_literal: true

module SpacesHelper
  def render_shelf_button(space)
    capture do
      concat button('Show', space_shelf_path(space), method: :post) if space.may_show?
      concat button('Remove', space_shelf_path(space), method: :delete, class: 'btn btn-info') if space.may_hide?
    end
  end

  def space_item(space, &block)
    data = {
      'space-id': space.id, 'space-name': space.name, 'space-latitude': space.position.latitude,
      'space-longitude': space.position.longitude, 'space-status': space.is_available?, 'space-path': space_path(space)
    }
    content_tag :article, class: 'article space', data: data, &block
  end

  def rating_star_style(score)
    case score
    when (0.0.next_float..0.5) then 'fa-star-half-o'
    when (0.5.next_float..Float::INFINITY) then 'fa-star'
    else 'fa-star-o'
    end
  end

  def render_rating_icons(score)
    capture do
      Array.new(5).map do
        concat content_tag :i, '', class: "fa #{rating_star_style(score)}"
        score -= 1
      end
    end
  end

  def render_addational_rules(space)
    return '' if space.spaceable.other_rules.blank?

    content_tag :li, class: 'space-information__rules-item' do
      "Other: #{space.spaceable.other_rules}"
    end
  end

  def space_rules(space)
    space.spaceable.rules.map { |index| SpaceOption.rules(space.spaceable_type.downcase, true)[index] }
  end

  def space_facilities(space)
    space.spaceable.facilities.map { |index| SpaceOption.facilities(space.spaceable_type.downcase, true)[index] }
  end

  def space_features(space)
    space.spaceable.features.map { |index| SpaceOption.features(space.spaceable_type.downcase, true)[index] }
  end

  def space_minimum_rent_days(space)
    SpaceOption.minimum_rent_days(space.spaceable_type.downcase, true)[space.minimum_rent_days]
  end

  def render_space_area(space)
    return unless space.area.positive?

    content_tag :li, class: 'space-information__property-item' do
      capture do
        concat content_tag :i, nil, class: 'fa fa-expand mr-2'
        concat "Size: #{space.area}sqm"
        concat ", Height: #{space.height}m" unless space.height.nil?
      end
    end
  end

  def dates_of_booking_slots(booking_slots)
    booking_slots&.map(&:date)&.map { |d| d.strftime('%Y-%m-%d') }
  end

  def space_available_dates(space, end_at = Float::INFINITY)
    space.available_dates(end_at: end_at).empty? ? 'booked_up' : space.available_dates(end_at: end_at).join(';')
  end

  def orders_start_days(space)
    space.order_taking_record(Time.zone.today).map { |e| e.start_at.strftime('%Y-%m-%d') }.join(';')
  end

  def discount_code_val(space)
    space.discount_code_before_type_cast || 1
  end

  def discount_code_checked?(space, option)
    if option == 'one_month' && space.draft? && space.discount_code.nil?
      true
    elsif space.discount_code == option || space.discount_code == 'one_and_two_months'
      true
    else
      false
    end
  end

  def has_discount_code?(space)
    space.draft? || space.discount_code.present?
  end

  def no_discount_code?(space)
    !space.draft? && space.discount_code.nil?
  end

  def render_discount_code_options(space)
    regex = /(.*?)_/
    content_tag :div, nil, class: 'discount-code-options pl-3' do
      %w[one_month two_months six_months].each.with_index(1) do |option, index|
        setting = option.slice(regex, 1)
        concat content_tag :div, nil, class: 'mt-2', &lambda {
          concat content_tag :input, nil, id: "discount-option-#{setting}", class: 'select-options', type: 'checkbox', value: index, checked: discount_code_checked?(space, option)
          concat content_tag :span, t("users.storages.new.#{option}_free"), class: 'ml-1'
        }
      end
    end
  end

  def render_create_listing_button(required_fields)
    if required_fields.present?
      return fake_display_button('Create New Listing', 'button button-secondary button-full-width')
    end

    link_to 'Create New Listing', new_user_storage_path(unauthenticated_path: become_a_host_path, msg: 'Please sign in or sign up to create your listing.'), class: 'button button-secondary'
  end

  def render_edit_promotion_button(required_fields, space)
    if required_fields.present?
      return fake_display_button(t('users.space.edit_promotion'), 'list-panel__button bg-blue')
    end

    link_to t('users.space.edit_promotion'), edit_user_space_path(space, edit_promotion: 'true'), class: 'list-panel__button bg-blue'
  end

  def render_edit_listing_button(required_fields, space)
    if required_fields.present?
      return fake_display_button(t('users.space.edit'), 'list-panel__button bg-orange')
    end

    link_to t('users.space.edit'), edit_user_space_path(space), class: 'list-panel__button bg-orange'
  end

  def fake_display_button(text, style)
    link_to text, '#cannot-create-space-modal', class: style, data: { toggle: 'modal' }
  end

  def render_edit_profile_button(required_fields)
    link_to t('.edit_profile'), edit_profile_link(required_fields), class: 'btn bg-blue rounded py-2 px-3 text-white'
  end

  def edit_profile_link(required_fields)
    return edit_user_registration_path(identity: 'host') if required_fields.include?(t('.address'))
    return verification_path(identity: 'host') if required_fields.include?(t('.phone'))
    return bank_account_path(identity: 'host') if required_fields.include?(t('.bank_account'))

    host_contact_path(identity: 'host') if required_fields.include?(t('.contact'))
  end

  def display_required_fields_message(required_fields)
    alert_fields = content_tag :span, required_fields.join(', '), class: 'text-orange'
    t('.required_fields_message', fields: alert_fields).html_safe
  end

  def render_space_status_tag(space)
    status = if space.activated_order.present?
               'booked'
             elsif space.is_available?
               'available'
             else
               'not-available'
             end
    content_tag :span, t("spaces.space.status.#{status.underscore}"), class: "space-status space-status--#{status}"
  end
end
