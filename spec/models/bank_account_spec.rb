# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BankAccount, type: :model do
  it { is_expected.to define_enum_for(:country) }
  it { is_expected.to validate_presence_of(:user) }
  it { is_expected.to validate_presence_of(:country) }
  it { is_expected.to validate_presence_of(:bank_code) }
  it { is_expected.to validate_presence_of(:account_name) }
  it { is_expected.to validate_presence_of(:account_number) }
  it { is_expected.to validate_length_of(:bank_code).is_at_most(6) }
  it { is_expected.to validate_length_of(:account_name).is_at_most(32) }
  it { is_expected.to validate_length_of(:account_number).is_at_most(64) }

  it 'is immutable' do
    bank_account = create(:bank_account)

    expect { bank_account.update!(account_number: 1234) }.to raise_error(ActiveRecord::RecordInvalid)
  end
end
