# frozen_string_literal: true

class RatingsMailer < ApplicationMailer
  # send to guest for rating order's host
  def guest(order)
    load_and_send(order, :guest)
  end

  def host(order)
    load_and_send(order, :host)
  end

  private

  def load_and_send(resource, identity)
    @order = resource
    @user = @order.send(identity)
    target = identity == :guest ? :space : :guest
    @ratable = @order.send(target)
    mail(to: @user.email,
         subject: "Rate your experience with #{target.to_s.capitalize}, #{@ratable.name}", &WAYS)
  end
end
