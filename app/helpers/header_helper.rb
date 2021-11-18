# frozen_string_literal: true

module HeaderHelper
  def render_navigation
    capture do
      concat tel_menu_item
      if user_signed_in?
        create_user_menu
      else
        create_guest_menu
      end
    end
  end

  def tel_menu_item
    content_tag(:li, class: 'pc-only ml-1') do
      link_to 'tel:+65 6353 9325' do
        capture do
          concat content_tag(:i, '', class: 'ico ico-tel')
          concat '+65 6353 9325'
        end
      end
    end
  end

  def create_user_menu
    nav_user_dropdown
  end

  def nav_user_dropdown
    concat render '/shared/header_user_dropdown'
  end

  def create_guest_menu
    concat content_tag(:li, link_to(t('.sign_in'), '#signin-popup', class: 'js_nav_signin nav__signin-link d-block', data: { toggle: 'modal' }))
    concat content_tag(:li, link_to(t('.sign_up'), '#signup-popup', class: 'js-nav-signup btn btn-primary d-inline-block', data: { toggle: 'modal' }))
  end

  def nav_user_message_item
    style = ['nav__user-dropdown-item']
    style << 'unread' if any_user_unread_message?
    content_tag :li, link_to(t('.messages'), channels_path), class: style.join(' ')
  end

  def any_user_unread_message?
    current_user.unread_notification? || current_user.unread_message?(:any)
  end

  def render_header
    content_for(:header) || (render '/shared/common_headers')
  end
end
