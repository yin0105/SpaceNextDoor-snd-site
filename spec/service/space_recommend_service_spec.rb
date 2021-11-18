# frozen_string_literal: true

require 'rails_helper'

describe 'SpaceRecommendServiceSpec' do
  subject { SpaceRecommendService.new(@search_params).start! }

  before(:all) do
    Space.aasm.state_machine.config.no_direct_assignment = false
    @spaces = create_list(:space, SpaceRecommendService::RECOMMEND_NUM, :activated, :two_years)
  end

  it 'returns only activated spaces' do
    @spaces[0].update(status: :draft)
    @spaces[1].update(status: :pending)
    @spaces[2].update(status: :soft_deleted)
    @spaces[3].update(status: :deactivated)
    @search_params = {}

    expect(subject.size).to eq(SpaceRecommendService::RECOMMEND_NUM - 4)
  end

  context 'when user search by region' do
    before do
      region = Regions::AREA_LATLNG.map { |name, _latlgn| name }.sample
      @search_params = { region: region }
      @lat = Regions::AREA_LATLNG[region].latitude
      @lng = Regions::AREA_LATLNG[region].longitude
    end

    it 'returns nearest spaces' do
      expect(subject.first).to eq(Space.order_by_distance(@lat, @lng).first)
    end
  end

  context 'when user search by size' do
    before do
      @search_params = { size: '1.00..100.00' }
    end

    it 'returns smallest spaces' do
      expect(subject.first).to eq(Space.where('area > 1.0').order(area: :asc).first)
    end
  end

  context 'when user search by price' do
    before do
      @search_params = { price: '1.00..100.00' }
    end

    it 'returns spaces' do
      expect(subject.first).to eq(Space.all.order(daily_price_cents: :asc).first)
    end
  end

  context 'when user search by no params match' do
    before do
      @search_params = { region: 'some region', size: '9999..99999', price: '9999..99999' }
    end

    it 'returns spaces' do
      expect(subject.first).to be_kind_of(Space)
    end
  end

  context 'when user search without params' do
    before do
      @search_params = {}
    end

    it 'returns spaces' do
      expect(subject.first).to be_kind_of(Space)
    end
  end
end
