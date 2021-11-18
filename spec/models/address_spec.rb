# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Address, type: :model do
  before { allow(Google::Geocoding).to receive(:geocode).and_return({ latitude: 1, longitude: 1 }) }

  it { is_expected.to belong_to(:addressable) }
  it { is_expected.to validate_presence_of(:country) }
  it { is_expected.to validate_presence_of(:city) }
  it { is_expected.to validate_presence_of(:area) }
  it { is_expected.to validate_presence_of(:street_address) }

  describe 'life cycle' do
    subject(:address) { create(:address, country: 'Singapore', city: 'Singapore', street_address: '1 Stadium Dr') }

    describe 'create' do
      it 'sets the latitude and longitude' do
        address.save!
        expect(address.latitude).not_to be_nil
        expect(address.longitude).not_to be_nil
      end

      it 'sets the area automatically' do
        address.save!
        expect(address.area).not_to be_nil
      end
    end

    describe 'update' do
      it 'updates the latitude and longitude' do
        old_latitude = address.latitude
        old_longitude = address.longitude

        allow(Google::Geocoding).to receive(:geocode).and_return({ latitude: 2, longitude: 2 })
        address.update!(area: 'Tanglin', street_address: '56 Tanglin Road')

        expect(address.latitude).not_to be_nil
        expect(address.longitude).not_to be_nil
        expect(address.latitude).not_to eq(old_latitude)
        expect(address.longitude).not_to eq(old_longitude)
      end

      it 'updates the area automatically' do
        expect do
          address.update(street_address: '1 Stadium Dr', area: '')
          expect(address.area).to('Kallang')
        end
      end

      it 'not to updates the area automatically' do
        expect do
          address.update(street_address: 'Tekka Centre, Bukit Timah Rd', area: 'Ang Mo Kio')
          expect(address.area).to('Ang Mo Kio')
        end
      end

      it "already have area and change it but don't auto detect" do
        expect do
          address.update(area: 'Ang Mo Kio')
          expect(address.area).to('Ang Mo Kio')
        end
      end
    end
  end

  describe '#full' do
    context 'returns the combindination of country, area and street address for Singapore address' do
      it 'unit number present' do
        address = create(:address, country: 'Singapore')

        expected_full_address = <<-EOF.strip_heredoc.strip
          #{address.street_address},
          #{address.unit},
          #{address.area},
          Singapore
          #{address.postal_code}
        EOF

        expect(address.full).to eq(expected_full_address)
      end
    end
  end
end
