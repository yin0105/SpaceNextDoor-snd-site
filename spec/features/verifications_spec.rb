# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Verifications', type: :feature do
  before do
    sms = double(SmsService)
    allow(SmsService).to receive(:new).and_return(sms)
    allow(sms).to receive(:send_out)
  end

  let(:fake_phone) { '+65 6670-5255' }
  let(:user) { create(:user) }

  describe "User can't see verification without login" do
    let(:url) { verification_path }

    it_behaves_like('accessible by user')
  end

  context 'phone verify' do
    before { sign_in user }

    it 'ables to ask verification code' do
      visit verification_path
      within '.profile--verified-form' do
        fill_in 'Phone', with: fake_phone
        click_on 'Verification'
      end
      expect(page).to have_content('Phone verification code')
    end

    context 'has verification code' do
      let(:user) { create(:user, unconfirmed_phone: fake_phone) }
      let!(:verify) { create(:verification_code, user: user) }

      it 'can verify phone', :js do
        visit verification_path
        fill_in 'phone_verify_code', with: verify.code
        click_on 'verify'
        visit verification_path
        expect(first('.profile--form-group')).to have_content('Verified')
      end
    end
  end
end
