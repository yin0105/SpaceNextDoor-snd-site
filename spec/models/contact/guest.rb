# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Contact::Guest, type: :model do
  let(:user) { create(:user) }
  let(:guest_contact) { create(:contact, user: user, type: :guest) }
  let(:new_guest_contact) { create(:contact, type: :guest) }

  describe 'build contact' do
    it 'guest has a contact' do
      guest_contact
      expect(user.as_guest.contact.id).to eq(guest_contact.id)
    end

    it 'guest contact has been exists' do
      guest_contact
      expect { user.as_guest.contact << new_guest_contact }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
