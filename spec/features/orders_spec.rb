# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Orders', type: :feature do
  let(:url) { new_order_path(order: { space_id: space.id }) }
  let(:user) { create(:user, :with_payment_method, :with_phone, :with_guest_contact) }
  let(:space) { create(:space, :activated, :two_years) }

  before do
    allow(Stripe::Charge).to receive(:create).and_return('id' => Faker::Crypto.sha1)
  end

  describe 'accessible guard' do
    it_behaves_like('accessible by user')
  end

  describe 'create order', :js do
    before { sign_in user }

    def fill_in_dates
      visit url
      page.evaluate_script("$('.order_start_at [data-datepicker]').flatpickr().setDate('#{Time.zone.now.to_date}')")
      page.evaluate_script("$('.order_end_at [data-datepicker]').flatpickr().setDate('#{2.months.from_now.to_date}')")
      page.execute_script('$("#order_term").click()')
      click_on 'Pay'
    end

    it 'fill date to create order' do
      fill_in_dates
      expect(page).to have_content('Your payment is successful!')
    end

    it 'date inputs disabled' do
      visit url

      expect(find('.order_start_at input')[:disabled]).to eq('true')
      expect(find('.order_end_at input')[:disabled]).to eq('true')
    end

    # TODO: update spec
    # it "cancel long lease order" do
    #   fill_in_dates
    #   visit orders_path
    #   expect(page).to have_content('Cancel Renewal')
    #   click_on 'Cancel Renewal'
    #   page.execute_script("$('[data-datepicker]').val('#{Time.zone.now.to_date}')")
    #   click_on 'Terminate'
    #   expect(page).to have_content('your order has been canceled')
    # end
  end
end
