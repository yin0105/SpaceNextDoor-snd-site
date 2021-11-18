# frozen_string_literal: true

module ViewHelper
  def button(name, target, style = 'primary', **options)
    options ||= {}
    options[:class] = merge_classes(options[:class] || '', "btn btn-#{style}")
    link_to name, target, **options
  end

  def merge_classes(origin, new)
    (origin.split(' ') + new.split(' ')).uniq.join(' ')
  end

  def home_page?
    current_page?(root_path)
  end

  def render_user_registration_modal
    return if user_signed_in?

    capture do
      concat render 'shared/signin_modal'
      concat render 'shared/signup_modal'
    end
  end

  def tax_links
    {
      sg_href: link_to('Here', '#', target: '_blank', rel: 'noopener'),
      hk_href: link_to('Here', '#', target: '_blank', rel: 'noopener')
    }
  end

  def status_color(record)
    if cancelled_long_lease?(record)
      return content_tag :span, 'Notice Given', class: "space-status space-status--#{record.status}"
    end

    content_tag :span, record.status.titleize, class: "space-status space-status--#{record.status}"
  end

  def should_open_signup_modal
    (flash[:unauthenticated] || false).to_s
  end

  def render_signin_alert_message
    return unless flash[:unauthenticated]

    content_tag :div, class: 'alert alert-warning' do
      content_tag :p, flash[:alert]
    end
  end

  def link_to_location(addressable, **options)
    options[:data] = {} if options[:data].blank?
    options[:data].merge!(addressable.position.to_h.merge(location: true))
    link_to addressable.location, nil, options
  end

  def render_share_modal_button(space)
    data = {
      'space-name': space.name,
      'share-mail-url': share_mail_url(space),
      'space-url': space_url(space),
      'toggle': 'modal',
      'target': '#social-popup'
    }
    content_tag :a, class: 'share js-social-share', data: data do
      content_tag :i, nil, class: 'ico ico-share'
    end
  end

  def share_mail_url(space)
    mail_subject = "?subject=#{t('snd.share.mail_subject')}"
    mail_info = "&body=#{t('snd.share.mail_info', name: space.name, url: space_url(space))}"
    "mailto:#{mail_subject} #{mail_info}"
  end

  def facebook_sdk_src
    return '//connect.facebook.net/en_US/sdk.js' if Rails.env.production? || Rails.env.staging?

    '//connect.facebook.net/en_US/sdk/debug.js'
  end

  def render_end_date(order, format)
    return 'Not decided' if order.long_term && order.long_term_cancelled_at.nil?
    return l order.long_term_cancelled_at, format: format if order.long_term

    l order.end_at, format: format
  end

  def render_promotion(order)
    return t('mails.discount_code.one_month') if order.discount_code == 'one_month'
    return t('mails.discount_code.two_months') if order.discount_code == 'two_months'
    return t('mails.discount_code.six_months') if order.discount_code == 'six_months'

    t('mails.discount_code.none')
  end

  def render_order_policies(order)
    last_policies = order.insurance_enable? ? ", #{link_to 'Privacy Policy', privacy_path, target: 'blank'} and #{link_to 'Insurance Terms & Conditions', insurance_terms_path, target: '_blank', rel: 'noopener'}." : " and #{link_to 'Privacy Policy', privacy_path, target: 'blank'}."
    "I confirm I have read and agree to Space Next Door’s  #{link_to 'Terms Of Service', terms_of_service_path, target: 'blank'}, #{link_to 'Cancellation Policy', cancellation_policy_path, target: 'blank'}" + last_policies
  end

  private

  def cancelled_long_lease?(record)
    record.class.name == 'Order' && record.cancellation_notice_given?
  end
end
