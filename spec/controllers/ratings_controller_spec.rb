# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RatingsController, type: :controller do
  before(:all) do
    @space = create(:space, :two_years, :activated)
    @channel = create(:channel, space: @space)
  end

  describe 'PUT #update' do
    before do
      @order = create(:order, :completed, channel: @channel, space: @space)
      @place = request.env['HTTP_REFERER'] = root_url
    end

    let(:rating_for_host) { @order.ratings.find_by(ratable_type: :User, ratable_id: @order.host.id) }
    let(:rating_for_space) { @order.ratings.find_by(ratable_type: :Space, ratable_id: @order.space.id) }
    let(:rating_for_guest) { @order.ratings.find_by(ratable_type: :User, ratable_id: @order.guest.id) }

    describe 'success' do
      context 'as guest' do
        before { login(@order.guest.as_user) }

        it 'redirect to :back, after rating for host is updated' do
          put :update, params: { profile_id: @order.host.id, id: rating_for_host.id, rating: { rate: (0..5).to_a.sample } }
          expect(response).to redirect_to(@place)
        end

        it 'redirect to :back, after rating for space is updated' do
          put :update, params: { space_id: @order.space.id, id: rating_for_space.id, rating: { rate: (0..5).to_a.sample } }
          expect(response).to redirect_to(@place)
        end
      end

      context 'as host' do
        before { login(@order.host.as_user) }

        it 'redirect to :back, after rating for guest is updated' do
          put :update, params: { profile_id: @order.guest.id, id: rating_for_guest.id, rating: { rate: (0..5).to_a.sample } }
          expect(response).to redirect_to(@place)
        end
      end
    end

    describe 'fail' do
      before { login(@order.guest.as_user) }

      it "render 'channels/show', when updaing fail" do
        put :update, params: { profile_id: @order.host.id, id: rating_for_host.id, rating: { rate: 100 } }
        expect(response).to render_template('channels/show')
      end
    end
  end
end
