# frozen_string_literal: true

module ApplicationHelper
  def flash_class_for(type)
    {
      success: 'alert-success',
      error: 'alert-danger',
      alert: 'alert-warning',
      notice: 'alert-info'
    }[type.to_sym] || type.to_s
  end

  def flash_messages
    return if flash[:unauthenticated]

    flash.each do |type, message|
      concat(
        content_tag(:div, nil, class: "alert alert-dismissable #{flash_class_for(type)}") do
          concat content_tag(:button, '×', class: 'close border-0 font-size-large text-white', data: { dismiss: 'alert' })
          concat message
        end
      )
    end
    nil
  end

  def active_link_to(text, path, options = {})
    active_class = options[:active] || 'active'
    options.delete(:active)
    options[:class] = "#{options[:class]} #{active_class}" if current_page?(path)

    link_to(text, path, options)
  end

  def page_scope
    params.slice(:controller, :action).values.map { |value| value.split('/') }.flatten
  end

  def page_name_defined?
    I18n.exists?([page_scope, :title].join('.'))
  end

  def localize_page_name
    return unless page_name_defined?

    t(:title, scope: page_scope)
  end

  def page_name
    page_title = content_for(:title) || localize_page_name
    name = [t('snd.sitename')]
    name.unshift page_title if page_title.present?

    name.join ' | '
  end

  def page_description_defined?
    I18n.exists?([page_scope, :description].join('.'))
  end

  def localize_page_description
    return t(:description, scope: :snd) unless page_description_defined?

    t(:description, scope: page_scope)
  end

  def page_description
    content_for(:description) || localize_page_description
  end

  def meta_robots_content
    return if Rails.env.production?

    tag(:meta, { name: 'robots', content: 'noindex, nofollow' })
  end
end
