# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Contact::Host, type: :model do
  let(:user) { create(:user) }
  let(:host_contact) { create(:contact, user: user, type: :host) }
  let(:new_host_contact) { create(:contact, type: :host) }

  describe 'build contact' do
    it 'host has a contact' do
      host_contact
      expect(user.as_host.contact.id).to eq(host_contact.id)
    end

    it 'host contact has been exists' do
      host_contact
      expect { user.as_host.contact << new_host_contact }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
