# frozen_string_literal: true

class ChannelsController < ApplicationController
  include Channels::MessageConstructor # build_message, set_messages, message_scope
  include Channels::RatingsFilter # load_pending_ratings
  include IdentityChecking # identity(klass)

  def index
    load_channels
    authorize_resource
  end

  # used in channels#index page
  def show
    load_channel
    load_messages
    authorize_resource
    load_pending_ratings
    build_message
    set_messages
  end

  # used in spaces#show page
  def create
    build_channel
    authorize_resource
    save_channel
  end

  private

  def load_channels
    @channels ||= channel_scope.with_messages.includes(:space, host: [:avatar]).page(params[:page])
  end

  def load_channel
    @channel ||= channel_scope.find_by(id: params[:id])
  end

  def build_channel
    @channel ||= Channel.where(
      guest: current_user,
      space_id: sanitized_params[:space_id]
    ).first_or_initialize do |c|
      c.attributes = channel_params
    end
  end

  def save_channel
    @channel.save if @channel.new_record?

    if @channel.errors.empty?
      redirect_to channel_path(@channel)
    else
      redirect_to spaces_path, flash: { error: @channel.errors.full_messages.join(', ') }
    end
  end

  def channel_scope
    identification = if action_name == 'show'
                       "current_#{identity(Channel)}"
                     else
                       "current_#{params.fetch(:identity, 'guest')}"
                     end
    @scope ||= send(identification).channels
  end

  def sanitized_params
    params.require(:channel).permit(:space_id)
  end

  def channel_params
    sanitized_params.merge(
      guest_id: current_user.id,
      orders_attributes: { o: order_params }
    )
  end

  def order_params
    { space_id: sanitized_params[:space_id], guest_id: current_user.id }
  end
end
