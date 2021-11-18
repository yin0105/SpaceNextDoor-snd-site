# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ChannelsController, type: :controller do
  def model_scope
    Channel
  end

  before(:all) do
    @user = create(:user)
    @guest_space = create(:space)
    @host_space = create(:space, user: @user)

    @guest_channel_with_ratings_and_messages = create(:channel, :with_completed_orders, space: @guest_space, guest: @user.as_guest)
    @guest_channels_with_messages = create_list(:channel, 2, :with_messages, space: @guest_space, guest: @user.as_guest, sender: :host)

    @host_channel_with_ratings_and_messages = create(:channel, :with_completed_orders, space: @host_space)
    @host_channels_with_messages = create_list(:channel, 2, :with_messages, space: @host_space)

    @somebody = create(:user)
    @other_space = create(:space, user: @somebody)
  end

  before { login(@user) }

  describe 'GET #index' do
    subject { get :index }

    it 'return http success' do
      subject
      expect(response).to have_http_status(:success)
    end

    context 'guest-related channels' do
      subject { get :index, params: { identity: :guest } }

      before { @guest_channel = create(:channel, space: @guest_space, guest: @user.as_guest) }

      it 'only display channels which is related to user as guest and contains messages' do
        subject
        expect(assigns[:channels].count).to eq(3)
        expect(assigns[:channels].map(&:guest_id).reject { |id| id == @user.id }).to be_empty
      end
    end

    context 'host-related channels' do
      subject { get :index, params: { identity: :host } }

      before { @host_channel = create(:channel, space: @host_space) }

      it 'only display channels which is related to user as guest and contains messages' do
        subject
        expect(assigns[:channels].count).to eq(3)
        expect(assigns[:channels].map(&:host_id).reject { |id| id == @user.id }).to be_empty
      end
    end
  end

  describe 'GET #show' do
    subject { get :show, params: { id: @channel.id } }

    before { @channel = @guest_channels_with_messages.first }

    context 'without ratings' do
      it 'return http success' do
        subject
        expect(response).to have_http_status(:success)
      end

      it 'channel has no ratings' do
        subject
        expect(assigns[:pending_ratings]).to be_empty
      end
    end

    context 'with unread messages' do
      it "update messages' read_at with Time.zone.now" do
        expect(@channel.messages.unread.count).to be > 0
        subject
        expect(assigns[:channel].messages.unread.count).to eq(0)
      end
    end

    context 'with ratings' do
      subject { get :show, params: { id: @channel.id } }

      before { @channel = @guest_channel_with_ratings_and_messages }

      it 'display correct ratings related to user' do
        subject
        expect(assigns[:pending_ratings].count).to eq(2)
        expect(assigns[:pending_ratings].reject { |rating| rating.user_id == @user.id }).to be_empty
      end

      it 'only display pending ratings' do
        subject
        expect(assigns[:pending_ratings].reject(&:pending?)).to be_empty
      end
    end
  end

  describe 'POST #create' do
    def create_channel(space = nil)
      post :create, params: { channel: { space_id: space&.id } }
    end

    describe 'success' do
      context "if it's already existed" do
        it 'reload old channel' do
          create(:channel, space: @other_space, guest: @user.as_guest)
          expect { create_channel(@other_space) }.to change(model_scope, :count).by(0)
        end
      end

      context "there isn't old channel" do
        it 'create a channel' do
          expect { create_channel(@other_space) }.to change(model_scope, :count).by(1)
        end

        it 'redirect_to orders_path' do
          create_channel(@other_space)
          expect(response).to redirect_to channel_path(assigns[:channel])
        end
      end
    end

    describe 'fail' do
      context 'no space_id parameter is passed' do
        it 'assign a newly created but unsaved channel' do
          create_channel
          expect(assigns[:channel]).to be_a_new(model_scope)
        end

        it 'redirect_to spaces#index' do
          create_channel
          expect(assigns[:channel]).to redirect_to spaces_path
        end
      end

      context 'host contact himself' do
        it 'assign a newly created but unsaved channel' do
          create_channel(@host_space)
          expect(assigns[:channel]).to be_a_new(model_scope)
        end
      end
    end
  end
end
