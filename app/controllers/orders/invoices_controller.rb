# frozen_string_literal: true

module Orders
  class InvoicesController < ApplicationController
    def show
      @identity ||= params.fetch(:identity, :guest)
      @payment = Payment.find(params[:id])

      authorize! :read, @payment
      render layout: false
    end
  end
end
