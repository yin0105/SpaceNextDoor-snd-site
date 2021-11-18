# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Channels::MessagesController, type: :controller do
  before(:all) do
    @host = create(:user)
    @user =  create(:user)
    @space = create(:space, :activated, :two_years, user: @host)
    @channel = create(:channel, space: @space, guest: @user.as_guest)
  end

  before { login(@user) }

  def model_scope
    Message
  end

  describe 'POST #create' do
    let(:attr) { { content: Faker::Lorem.paragraphs.join(' ') } }

    context 'success' do
      subject { post :create, params: { channel_id: @channel.id, message: attr } }

      it 'create message' do
        expect { subject }.to change(model_scope, :count).by(1)
      end

      it 'redirect to channel_path' do
        subject
        expect(response).to redirect_to channel_path(assigns[:channel])
      end
    end

    context 'fail' do
      subject { post :create, params: { channel_id: channel.id, message: attr } }

      let(:channel) { create(:channel, space: @space) }

      it 'a newly but unsaved message' do
        subject
        expect(assigns[:message]).to be_a_new(model_scope)
      end

      it 'render channels#show' do
        subject
        expect(assigns[:message]).to render_template('channels/show')
      end
    end
  end
end
