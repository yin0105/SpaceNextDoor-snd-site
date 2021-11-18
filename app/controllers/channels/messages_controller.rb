# frozen_string_literal: true

module Channels
  class MessagesController < ApplicationController
    def create
      build_message
      authorize_resource
      save_message
    end

    private

    def build_message
      @message ||= message_scope.new
      @message.attributes = message_params
    end

    def save_message
      if @message.save
        redirect_to channel_path(current_channel)
      else
        @messages = current_channel.messages.includes(:user)
        render 'channels/show'
      end
    end

    def message_params
      params.require(:message).permit(
        :content,
        images_attributes: %i[id _destroy]
      )
    end

    def message_scope
      current_user.messages.where(channel: current_channel)
    end

    def current_channel
      @channel ||= channel_scope.find_by(id: params[:channel_id])
    end

    def channel_scope
      Channel
    end
  end
end
