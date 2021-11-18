# frozen_string_literal: true

module SpacesShowHelper
  def render_save_space_to_favorite_button(space, icon_only = false)
    # TODO: Implement unsave button
    link_to space_favorite_path(space), class: 'text-white space__favorite-button', method: :post do
      concat content_tag :i, nil, class: 'space__favorite-icon fa fa-heart-o'
      concat 'Save to Wish List' unless icon_only
    end
  end

  def space_facilities(space)
    space.spaceable.facilities.map { |index| SpaceOption.facilities(space.spaceable_type.downcase, true)[index] }
  end

  def space_features(space)
    space.spaceable.features.map { |index| SpaceOption.features(space.spaceable_type.downcase, true)[index] }
  end

  def check_size_estimator(space)
    return 'small' if space.area <= 3
    return 'medium' if space.area > 3 && space.area <= 6
    return 'large' if space.area > 6 && space.area <= 9

    'extra_large'
  end

  def render_find_out_more_button(space)
    return if space.user == current_user

    link_to 'Find Out More!', new_find_out_more_path(space_id: space.id), class: 'button button-primary button-full-width js-find-out-more-btn'
  end

  def render_book_space_button(space)
    return if space.user == current_user

    content_tag :button, 'Book', class: 'button button-secondary button-full-width border-0'
  end

  def space_available_dates(space, end_at = Float::INFINITY)
    space.available_dates(end_at: end_at).empty? ? 'booked_up' : space.available_dates(end_at: end_at).join(';')
  end

  def space_min_rent_days(space)
    space.minimum_rent_days
  end

  def render_google_map_layout
    return render partial: 'hide_map_spaces' if hide_map?

    render partial: 'show_map_spaces'
  end

  def hide_map?
    params[:hide_map].present?
  end

  def insurance_options
    I18n.t('insurance.options').map(&:values)
  end
end
