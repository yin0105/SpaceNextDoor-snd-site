# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Orders::InvoicesController, type: :controller do
  before(:all) do
    @order = create(:order, :with_payments)
    @payment = @order.payments.valid.first
  end

  describe 'GET #show' do
    before { login(@order.guest.as_user) }

    def show_invoice(order, invoice)
      get :show, params: { order_id: order.id, id: invoice.id }
    end

    it 'return http success' do
      show_invoice(@order, @payment)
      expect(response).to have_http_status(:success)
    end

    it 'render partial' do
      show_invoice(@order, @payment)
      expect(response).to render_template('invoices/show')
    end
  end
end
