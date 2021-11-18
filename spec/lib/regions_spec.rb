# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Regions, type: :model do
  describe 'class constants' do
    describe 'Regions::REGIONS' do
      subject { Regions::REGIONS }

      it { is_expected.to be_kind_of(Hash) }
      it { is_expected.to have_key('SGP') }
    end

    describe 'Regions::COUNTRY_ENUM_KEYS' do
      subject { Regions::COUNTRY_ENUM_KEYS }

      it { is_expected.to be_kind_of(Hash) }
      it { is_expected.to have_key('Singapore') }
    end

    describe 'Regions::CITY_ENUM_KEYS' do
      subject { Regions::CITY_ENUM_KEYS }

      it { is_expected.to be_kind_of(Hash) }
      it { is_expected.to have_key('Singapore') }
    end

    describe 'Regions::AREA_ENUM_KEYS' do
      subject { Regions::AREA_ENUM_KEYS }

      it { is_expected.to be_kind_of(Hash) }
      it { is_expected.to have_key('Ang Mo Kio') }
    end

    describe 'Regions::COUNTRY_CODES' do
      subject { Regions::COUNTRY_CODES }

      it { is_expected.to be_kind_of(Hash) }
      it { is_expected.to have_key('Singapore') }
    end

    describe 'Regions::CITY_CODES' do
      subject { Regions::CITY_CODES }

      it { is_expected.to be_kind_of(Hash) }
      it { is_expected.to have_key('Singapore') }
    end

    describe 'Regions::AREA_CODES' do
      subject { Regions::AREA_CODES }

      it { is_expected.to be_kind_of(Hash) }
      it { is_expected.to have_key('Ang Mo Kio') }
    end
  end
end
