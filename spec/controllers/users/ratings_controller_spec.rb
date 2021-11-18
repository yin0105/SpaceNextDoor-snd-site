# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::RatingsController, type: :controller do
  before(:all) do
    @user = create(:user)

    space = create(:space, :activated, user: @user, dates: [Time.zone.today])
    other_space = create(:space, :activated, dates: [Time.zone.today])

    order_as_host = create(:order, :active, space: space)
    order_as_guest = create(:order, :active, space: other_space, guest: @user.as_guest)

    @user_completed_host_ratings = create_list(:rating, 3, :completed, order: order_as_host, target: :host)
    @user_incompleted_host_ratings = create_list(:rating, 3, order: order_as_host, target: :host)

    @user_completed_guest_ratings = create_list(:rating, 3, :completed, order: order_as_guest, target: :guest)
    @user_incompleted_guest_ratings = create_list(:rating, 3, order: order_as_guest, target: :guest)
  end

  describe 'GET #index' do
    before { login(@user) }

    def index_ratings(type)
      get :index, params: { identity: type }
    end

    context 'ratings received when being guest' do
      it 'return all completed guest ratings' do
        index_ratings('guest')
        expect(assigns[:ratings]).to match_array(@user_completed_guest_ratings)
      end
    end

    context 'ratings received when being host' do
      it 'return all completed host ratings' do
        index_ratings('host')
        expect(assigns[:ratings]).to match_array(@user_completed_host_ratings)
      end
    end
  end
end
