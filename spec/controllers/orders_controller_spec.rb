# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrdersController, type: :controller do
  let(:user) { create(:user, :with_payment_method, :with_phone) }

  before { login(user) }

  before(:all) { @space = create(:space, :activated, :two_years) }

  describe 'GET #index' do
    before do
      @guest_orders = create_list(:order, 3, space: @space, guest: user.as_guest)
      @guest_invalid_orders = create_list(:order, 3, :with_invalid_data, space: @space, guest: user.as_guest)
      @host_orders = create_list(:order, 3, space: @space, host: user.as_host)
    end

    def index_orders
      get :index
    end

    it 'returns http success' do
      index_orders
      expect(response).to have_http_status(:success)
    end

    it 'only display valid guest orders' do
      index_orders
      expect(assigns[:orders]).to match_array(@guest_orders)
    end
  end

  describe 'GET #show' do
    before do
      @guest_order = create(:order, space: @space, guest: user.as_guest)
      @host_order = create(:order, space: @space, host: user.as_host)
    end

    def show_order(order)
      get :show, params: { id: order.id }
    end

    it 'returns http success' do
      show_order(@guest_order)
      expect(response).to have_http_status(:success)
    end

    it 'only display valid guest order' do
      expect { show_order(@host_order) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe 'GET #new' do
    def build_order(space)
      get :new, params: { order: { space_id: space.id } }
    end

    context 'pending order exist' do
      before { @pending_order = create(:order, space: @space, guest: user.as_guest, start_at: nil, end_at: nil) }

      it 'return http success' do
        build_order(@space)
        expect(response).to have_http_status(:success)
        expect(assigns[:order]).not_to be_a_new(DirectOrder)
      end
    end

    context 'no pending order' do
      it 'returns http success' do
        build_order(@space)
        expect(response).to have_http_status(:success)
        expect(assigns[:order]).to be_a_new(DirectOrder)
      end
    end

    context 'space is not activated' do
      let(:space) { create(:space, dates: [Time.zone.today]) }

      it 'not to returns http success' do
        build_order(space)
        expect(response).not_to have_http_status(:success)
      end
    end
  end

  describe 'POST #create' do
    let(:model_scope) { DirectOrder }
    let(:attr) do
      { space_id: @space.id,
        start_at: Time.zone.today,
        end_at: @space.minimum_rent_days.days.from_now.to_date,
        term: 1 }
    end

    def create_order(hash = {})
      post :create, params: { order: attr.merge(hash) }
    end

    context 'success' do
      before do
        service = double(CreatePaymentService, {})
        allow(service).to receive(:start!)
        allow(CreatePaymentService).to receive(:new).and_return(service)
      end

      it 'create a order' do
        expect { create_order }.to change(model_scope, :count).by(1)
      end

      it 'redirect_to orders_path' do
        create_order
        expect(response).to redirect_to well_done_order_payments_path(assigns(:form).order)
      end
    end

    context 'fail' do
      context 'parameters are invalid' do
        it 'assigns a newly created but unsaved order' do
          create_order(start_at: 1.day.ago.to_date)
          expect(assigns[:order]).to be_a_new(model_scope)
        end

        it "re-renders the 'new' template" do
          create_order(start_at: 1.day.ago.to_date)
          expect(assigns[:order]).to render_template('orders/new')
        end
      end

      context 'host make an order with himself' do
        let(:user) { @space.user }

        before do
          logout
          login(user)
        end

        it 'assigns a newly created but unsaved order' do
          create_order(space_id: @space.id)
          expect(assigns[:order]).to be_a_new(model_scope)
        end
      end
    end
  end

  describe 'POST #update' do
    before do
      service = double(CreatePaymentService, {})
      allow(service).to receive(:start!)
      allow(CreatePaymentService).to receive(:new).and_return(service)
      @pending_order = create(:order, space: @space, guest: user.as_guest, start_at: nil, end_at: nil)
    end

    let(:attr) do
      { start_at: Time.zone.today,
        end_at: @space.minimum_rent_days.days.from_now.to_date,
        term: 1 }
    end

    def update_order(order, hash = {})
      post :update, params: { id: order.id, space_id: @space.id, order: attr.merge(hash) }
    end

    it 'update successfully' do
      update_order(@pending_order)
      expect(response).to redirect_to(well_done_order_payments_path(assigns(:order)))
    end
  end

  describe 'POST #edit_insurance' do
    before do
      @space = create(:space, :activated, :default_insurance_enable_property)
      @guest_order = create(:order, space: @space, guest: user.as_guest)
      @host_order = create(:order, space: @space, host: user.as_host)
    end

    def edit_insurance(order)
      get :edit_insurance, params: { id: order.id }
    end

    it 'returns http success' do
      edit_insurance(@guest_order)
      expect(response).to have_http_status(:success)
    end

    it 'only display valid guest order' do
      expect { edit_insurance(@host_order) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'only display insurance enable' do
      insurance_attributes = Insurance.insurance_attributes(false, nil)
      @guest_order.update(insurance_attributes)
      edit_insurance(@guest_order)
      expect(response).to redirect_to(orders_path)
    end
  end

  describe 'POST #update_insurance' do
    before do
      @space = create(:space, :activated, :default_insurance_enable_property)
      @order = create(:order, :insurance_enable, space: @space, guest: user.as_guest)
    end

    def update_insurance(order, type)
      post :update_insurance, params: { id: order.id, insurance_type: type }
    end

    it 'update successfully' do
      type = Insurance::INSURANCE_OPTIONS.keys.sample
      update_insurance(@order, type)
      expect(assigns[:order].insurance_type).to eq(type)
      expect(response).to redirect_to(orders_path)
    end
  end
end
