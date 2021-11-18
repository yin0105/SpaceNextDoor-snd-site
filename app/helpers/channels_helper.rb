# frozen_string_literal: true

module ChannelsHelper
  def rating_path(resource:, rating:)
    if rating.ratable_type == 'space'
      space_rating_path(resource, rating)
    else
      profile_rating_path(resource, rating)
    end
  end

  def render_channel_navigation
    content_tag :ul do
      capture do
        %i[guest host notification].each { |type| concat render_channel_navigation_item(type) }
      end
    end
  end

  def render_channel_navigation_item(type)
    style = ['channel-index__navigation d-inline-block p-3']
    style << 'active' if current_channel_page?(type)
    style << 'unread' if any_channel_unread_at(type)
    content_tag :li, class: style.join(' ') do
      if type == :notification
        link_to t("channel.tab.#{type}"), notifications_path, class: 'text-gray-deep'
      else
        link_to t("roles.#{type}"), channels_path(identity: type), class: 'text-gray-deep'
      end
    end
  end

  def current_channel_page?(type)
    return current_page?(notifications_path) if type == :notification

    current_page?(channels_path) && params.fetch(:identity, :guest).to_sym == type
  end

  def any_channel_unread_at(type)
    case type
    when :notification
      current_user.unread_notification?
    else
      current_user.unread_message?(type)
    end
  end

  def render_channel_book_space_button(channel)
    return unless channel.pending_order?

    link_to :book, new_order_path(space_id: channel.space.id), class: 'button bg-orange channel-show__space-book-button mx-auto'
  end

  def render_message_content(message)
    return if message.blank?

    link_to simple_format(message.content, {}, wrapper_tag: :span), message.channel, class: 'text-gray-deep'
  end

  def render_message_time(message)
    return if message.blank?

    l message.created_at, format: :date
  end
end
