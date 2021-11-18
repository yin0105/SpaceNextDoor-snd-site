# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::SpacesController, type: :controller do
  before(:all) do
    dates = Time.zone.today..1.day.from_now.to_date
    @user = create(:user)
    @spaces = create_list(:space, 2, :pending, user: @user, dates: dates)
    @activated_spaces = create_list(:space, 2, :activated, user: @user, dates: dates)
    @other_activated_spaces = create_list(:space, 2, :activated, dates: dates)

    @favorite_spaces = []
    @favorite_spaces << create(:favorite_space_relation, user: @user, space: @other_activated_spaces.first)
    @favorite_spaces << create(:favorite_space_relation, user: @user, space: @other_activated_spaces.last)
    create(:favorite_space_relation, space: @spaces.first)
  end

  before { login(@user) }

  describe 'GET #index' do
    def index_user_spaces(identity = 'guest')
      get :index, params: { identity: identity }
    end

    it 'show all favorite spaces' do
      index_user_spaces('guest')
      expect(assigns[:spaces]).to match_array(@favorite_spaces.map(&:space))
    end

    it 'show submitted spaces' do
      index_user_spaces('host')
      expect(assigns[:spaces]).to match_array(@activated_spaces + @spaces)
    end
  end

  describe 'GET #edit' do
    def edit_space(space)
      get :edit, params: { id: space.id }
    end

    context 'self-owned space' do
      let(:space) { @spaces.first }

      it 'http status 302' do
        edit_space(space)
        expect(assigns[:space]).to eq(space)
        expect(response).to redirect_to([:edit, :user, space.spaceable])
      end
    end

    context 'not self-owned space' do
      let(:space) { @other_activated_spaces.first }

      it 'raise error' do
        expect { edit_space(space) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'GET #well_done' do
    let(:space) { @spaces.first }

    it 'http status 200' do
      get :well_done, params: { id: space.id }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #query_spaces' do
    let(:space) { @spaces.first }

    context 'query by id with region' do
      it 'shoud return the space' do
        get :query_spaces, params: { field: space.id, region: space.address.area }
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('application/json')
        expect(JSON.parse(response.body)[0]['id']).to eq(space.id)
        expect(JSON.parse(response.body).length).to eq(1)
      end

      it 'with unknow region shoud return empty' do
        get :query_spaces, params: { field: space.id, region: 'Undefined' }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body).length).to eq(0)
      end
    end

    it 'query by name' do
      get :query_spaces, params: { field: space.name, region: space.address.area }
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to eq('application/json')
      expect(JSON.parse(response.body)[0]['id']).to eq(space.id)
    end
  end
end
