# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Notificaitons' do
  describe "User can't see notifications without login" do
    let(:url) { notifications_path }

    it_behaves_like('accessible by user')
  end
end
