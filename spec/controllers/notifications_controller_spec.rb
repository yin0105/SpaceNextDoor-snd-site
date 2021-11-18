# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NotificationsController, type: :controller do
  let(:threshold) { Notification::THRESHOLD.hours }
  let(:user) { create(:user) }

  before { login(user) }

  before(:all) { @notifications = create_list(:notification, 5) }

  describe 'GET #index' do
    def index_notifications
      get :index
    end

    it 'http_status code 200' do
      index_notifications
      expect(response).to have_http_status(:success)
    end

    it 'return all notifications' do
      index_notifications
      expect(assigns[:notifications]).to match_array(@notifications)
    end

    describe 'notifications_seen_at column' do
      context 'session is nil' do
        it 'update column' do
          expect(user.notifications_seen_at).to be_nil
          index_notifications
          expect(user.reload.notifications_seen_at).not_to be_nil
        end
      end

      context 'when notifications_seen_at is outdated' do
        it 'session is outdated' do
          user.update(notifications_seen_at: threshold.ago)
          index_notifications
          expect(user.reload.notifications_seen_at + 1.minute).to be > Time.zone.now
        end
      end

      context 'when notifications_seen_at is latest' do
        it 'session is the latest' do
          user.update(notifications_seen_at: Time.zone.now)
          index_notifications
          expect(user.reload.notifications_seen_at + threshold).to be > Time.zone.now
        end
      end
    end

    describe 'notifications include assign to user' do
      before do
        @notifications_with_assign_users = create_list(:notification_relation, 5, user: user)
        @other_user = create(:user)
      end

      context 'return notifications that notify all user and assign user' do
        it 'belongs to user' do
          index_notifications
          expect(assigns[:notifications].count).to eq 10
        end

        it 'belongs to other user' do
          login(@other_user)
          index_notifications
          expect(assigns[:notifications].count).to eq 5
        end
      end
    end
  end
end
