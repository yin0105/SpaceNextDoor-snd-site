# frozen_string_literal: true

class OrdersMailer < ApplicationMailer
  helper %i[spaces view]

  def activating(order)
    @order = order
    @user = order.host.as_user
    @payment = order.down_payment
    mail(to: @user.email,
         subject: 'You have received a booking on Space Next Door', &WAYS)
  end

  def will_expired_for_host(order)
    @order = order
    @user = order.host.as_user
    @payment = order.down_payment
    mail(to: @user.email,
         subject: "Your space booking by Guest, #{@order.guest.name} is expiring soon", &WAYS)
  end

  def will_expired_for_guest(order)
    @order = order
    @user = order.guest.as_user
    @payment = order.down_payment
    mail(to: @user.email,
         subject: 'Your booking with Space Next Door is expiring soon', &WAYS)
  end

  def cancellation_notice_given_for_guest(order)
    @order = order
    @space = order.space
    @user = order.guest.as_user
    mail(to: @user.email,
         bcc: Settings.notification.bcc_list,
         subject: 'Your termination notice has been received', &WAYS)
  end

  def cancellation_notice_given_for_host(order)
    @order = order
    @space = order.space
    @host = order.host.as_user
    @guest = order.guest.as_user
    mail(to: @host.email,
         subject: 'Termination notice for your space', &WAYS)
  end

  def long_lease_will_expired_for_host(order)
    @order = order
    @user = order.host.as_user
    @payment = order.down_payment
    mail(to: @user.email,
         subject: "Your space booking by Guest, #{@order.guest.name} is expiring soon", &WAYS)
  end

  def long_lease_will_expired_for_guest(order)
    @order = order
    @user = order.guest.as_user
    @payment = order.down_payment
    mail(to: @user.email,
         subject: 'Your booking with Space Next Door is expiring soon', &WAYS)
  end

  def insurance_will_changed_next_period(order)
    @order = order
    @user = order.guest.as_user
    @space = order.space
    if @order.insurance_enable?
      attachments['Insurance Terms and Conditions.pdf'] = File.read(Rails.root.join('public/insurance_terms.pdf'))
    end
    mail(to: @user.email,
         subject: 'Your insurance coverage is updated', &WAYS)
  end

  def transform_long_lease_for_guest(order)
    @order = order
    @user = order.guest.as_user
    @payment = order.last_payment
    mail(to: @user.email,
         subject: 'Your booking change request successful', &WAYS)
  end

  def transform_long_lease_for_host(order)
    @order = order
    @user = order.host.as_user
    @payment = order.last_payment
    mail(to: @user.email,
         subject: 'You have received a renewed booking', &WAYS)
  end
end
