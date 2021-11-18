# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SpacesController, type: :controller do
  before(:all) do
    @user = create(:user)
    @spaces = create_list(:space, 2, user: @user, dates: [Time.zone.today])
    @activated_spaces = create_list(:space, 3, :activated, user: @user, dates: [Time.zone.today])
    @booked_space = @activated_spaces.first
    @booked_space.booking_slots.first.update(status: :booked)
    @pending_space = create(:space, :pending, user: @user, dates: [Time.zone.today])
    @deactivated_space = create(:space, :deactivated, user: @user, dates: [Time.zone.today])
    @deleted_space = create(:space, :soft_deleted, user: @user, dates: [Time.zone.today])
  end

  describe 'GET #index' do
    before { get :index }

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'display only activated spaces' do
      expect(assigns(:spaces)).to match_array(@activated_spaces)
    end

    it 'sorting by created_at desc' do
      expect(assigns(:spaces).first).to eq(@activated_spaces.last)
    end

    it 'shows featured spaces first' do
      featured_spaces = create_list(:space, 3, :featured, :activated, user: @user, dates: [Time.zone.today])
      expect(assigns(:spaces).first).to eq(featured_spaces.last)
    end
  end

  describe 'display spaces with search params' do
    it 'with date' do
      get :index, params: { check_in: Time.zone.today }

      expect(assigns(:spaces).count).to eq(2)
      expect(assigns(:spaces)).not_to include(@booked_space)
    end

    it 'with size' do
      get :index, params: { size: 0..@booked_space.area }

      expect(assigns(:spaces)).to include(@booked_space)
    end

    it 'with price' do
      get :index, params: { price: 0..@booked_space.daily_price }

      expect(assigns(:spaces)).to include(@booked_space)
    end

    it 'with type' do
      get :index, params: { type: @booked_space.property }

      expect(assigns(:spaces)).to include(@booked_space)
    end

    context 'with sorting' do
      it 'when newest' do
        get :index, params: { sort: :created_at_desc }

        expect(assigns(:spaces).first).to eq(@activated_spaces.max_by(&:created_at))
      end

      it 'when area desc' do
        get :index, params: { sort: :area_desc }

        expect(assigns(:spaces).first).to eq(@activated_spaces.max_by(&:area))
      end

      it 'when area asc' do
        get :index, params: { sort: :area_asc }

        expect(assigns(:spaces).first).to eq(@activated_spaces.min_by(&:area))
      end

      it 'when daily price desc' do
        get :index, params: { sort: :daily_price_cents_desc }

        expect(assigns(:spaces).first).to eq(@activated_spaces.max_by(&:daily_price_cents))
      end

      it 'when daily price asc' do
        get :index, params: { sort: :daily_price_cents_asc }

        expect(assigns(:spaces).first).to eq(@activated_spaces.min_by(&:daily_price_cents))
      end
    end
  end

  describe 'GET #show' do
    let(:activated_space) { @activated_spaces.first }
    let(:draft_space) { @spaces.first }
    let(:pending_space) { @pending_space }
    let(:deactivated_space) { @deactivated_space }
    let(:deleted_space) { @deleted_space }

    def show_space(space)
      get :show, params: { id: space.id }
    end

    it 'no one can see deleted space' do
      expect { show_space(deleted_space) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    context 'no login' do
      it 'returns http success' do
        show_space(activated_space)
        expect(response).to have_http_status(:success)
      end

      it "non-host can't see other hosts' non-activated spaces" do
        expect { show_space(draft_space) }.to raise_error(ActiveRecord::RecordNotFound)
        expect { show_space(pending_space) }.to raise_error(ActiveRecord::RecordNotFound)
        expect { show_space(deactivated_space) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'host can see his not-deleted-spaces' do
      before { login(@user) }

      it 'host can see his draft spaces' do
        show_space(draft_space)
        expect(response).to have_http_status(:success)
      end

      it 'host can see his pending spaces' do
        show_space(pending_space)
        expect(response).to have_http_status(:success)
      end

      it 'host can see his pending spaces' do
        show_space(deactivated_space)
        expect(response).to have_http_status(:success)
      end
    end

    context 'ratings' do
      before do
        @order = create(:order, space: activated_space)
        @completed_ratings = create_list(:rating, 5, :completed, order: @order, target: :space)
        @ratings = create_list(:rating, 5, order: @order, target: :space)
      end

      it 'display completed ratings' do
        show_space(activated_space)
        expect(assigns[:evaluations]).to match_array(@completed_ratings)
      end
    end
  end
end
