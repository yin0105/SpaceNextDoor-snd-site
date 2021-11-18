# frozen_string_literal: true

module Channels
  module RatingsFilter
    extend ActiveSupport::Concern

    private

    def load_pending_ratings
      @pending_ratings ||= current_user.ratings.where(
        order_id: @channel.unrated_orders.map(&:id),
        rater_type: identity(Channel)
      ).pending
    end
  end
end
