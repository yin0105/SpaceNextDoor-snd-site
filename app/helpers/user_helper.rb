# frozen_string_literal: true

module UserHelper
  def render_user_verified_badge(user)
    return '' unless user.verified?

    content_tag :div, class: 'profile__verify-status font-size-small text-green' do
      concat content_tag :i, '', class: 'icon fa fa-check-circle'
      concat 'Verified'
    end
  end

  def render_profile_rating_navigation
    content_tag :ul do
      capture do
        %i[guest host].each { |identity| concat render_profile_rating_navigation_item(identity) }
      end
    end
  end

  def render_profile_rating_navigation_item(identity)
    style = ['profile-rating__navigation d-inline-block p-3']
    style << 'active' if current_profile_page?(identity)
    content_tag :li, class: style.join(' ') do
      link_to identity.to_s.capitalize, ratings_path(identity: identity)
    end
  end

  def current_profile_page?(identity)
    current_page?(ratings_path) && params.fetch(:identity, :guest).to_sym == identity
  end

  def render_space_navigation
    content_tag :ul do
      capture do
        %i[guest host].each { |identity| concat render_space_navigation_item(identity) }
      end
    end
  end

  def render_space_navigation_item(identity)
    style = ['user-space-index__navigation d-inline-block p-3']
    style << 'active' if current_space_page?(identity)
    content_tag :li, class: style.join(' ') do
      link_to t("users.space.tab.#{identity}"), user_spaces_path(identity: identity), class: 'text-gray-deep'
    end
  end

  def current_space_page?(identity)
    current_page?(user_spaces_path) && params.fetch(:identity, :host).to_sym == identity
  end

  def current_contact(role)
    current_user.public_send(role).contact
  end

  def render_space_availability(space)
    status = if space.activated_order.present?
               t('.status.booked')
             elsif space.is_available?
               t('.status.available')
             else
               t('.status.not_available')
             end
    content_tag :span, status
  end

  def render_edit_button_text(identity)
    identity == 'host' ? 'Next' : 'Save'
  end
end
