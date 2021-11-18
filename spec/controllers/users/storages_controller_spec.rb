# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::StoragesController, type: :controller do
  let(:user) { create(:user) }
  let(:image_1) { create(:image) }
  let(:image_2) { create(:image) }
  let(:pending_space) { create(:space, :two_days, user: user, without_storage: true) }
  let(:activated_space) { create(:space, :activated, :two_days, user: user, without_storage: true) }

  before { login(user) }

  describe 'GET #new' do
    def new_storage
      get :new
    end

    context 'without draft' do
      it 'returns http success' do
        new_storage
        expect(response).to have_http_status(:success)
        expect(assigns[:storage].class).to be < Storage::Form
      end
    end

    context 'with draft' do
      before do
        @storage = create(:storage, user: user, space: pending_space)
      end

      it 'returns http success' do
        new_storage
        expect(response).to have_http_status(:success)
        expect(assigns[:storage].id).to eq(@storage.id)
      end
    end
  end

  describe 'POST #create' do
    def create_storage(hash = {})
      attr = { category: 'business',
               features: [1, 2, 3],
               space_attributes: {
                 address: create(:address),
                 property: 'residential',
                 images_attributes: { "0": { id: image_1.id, description: '' }, "1": { id: image_2.id, description: '' } },
                 dates: [*Time.zone.now.to_date..Time.zone.now.to_date.next_year - 1.day].join(';')
               } }
      post :create, params: { storage: attr.merge(hash) }
    end

    context 'failure' do
      it 'render new' do
        create_storage(category: '')
        expect(response).to render_template('users/storages/new')
      end
    end

    context 'success' do
      it 'save a storage' do
        expect { create_storage }.to change(Storage, :count).by(1)
      end

      context 'status: create_step1 -> create_step_2' do
        it 'redirect to next page' do
          create_storage
          expect(response).to redirect_to new_user_storage_path
        end
      end

      context 'storage space avaliable dates' do
        it 'available days is 1 year' do
          create_storage
          expect(Storage.last.space.booking_slots.available.size).to eq(365)
        end

        it 'available days is 1 year' do
          create_storage(dates: [*Time.zone.now.to_date..Time.zone.now.to_date.next_year - 1.day].join(';'))
          expect(Storage.last.space.booking_slots.available.size).to eq(365)
        end
      end
    end

    context 'back' do
    end
  end

  describe 'GET #edit' do
    def edit_storage(storage)
      get :edit, params: { id: storage.id }
    end

    context 'updatable' do
      before { @storage = create(:storage, user: user, space: activated_space, edit_status: 16) }

      it 'http success' do
        edit_storage(@storage)
        expect(response).to have_http_status(:success)
      end

      it 'load storage' do
        edit_storage(@storage)
        expect(assigns[:storage].id).to eq(@storage.id)
      end
    end

    context 'not updatable' do
      before { @storage = create(:storage, user: user, space: activated_space, edit_status: 0) }

      it 'redirect' do
        edit_storage(@storage)
        expect(response).to redirect_to new_user_storage_path
      end
    end
  end

  describe 'POST #update' do
    def update_storage(storage, hash = {})
      put :update, params: { id: storage.id, storage: hash }
    end

    context 'failure' do
      before { @storage = create(:storage, user: user, space: activated_space, edit_status: 16) }

      it 'render new' do
        update_storage(@storage, category: '')
        expect(response).to render_template('users/storages/edit')
      end
    end

    context 'success' do
      before { @storage = create(:storage, user: user, space: activated_space, edit_status: 16) }

      it 'redirect to next page' do
        update_storage(@storage, features: [1])
        expect(response).to redirect_to edit_user_storage_path(assigns[:storage])
      end
    end

    context 'update dates success' do
      before { @storage = create(:storage, user: user, space: activated_space, edit_status: 4) }

      it 'available dates only 1' do
        update_storage(@storage, space_attributes: { id: activated_space.id, dates: activated_space.booking_slots.sample(1).join(';') })
        expect(activated_space.booking_slots.available.size).to eq(1)
        expect(activated_space.booking_slots.disabled.size).to eq(1)
      end
    end
  end
end
