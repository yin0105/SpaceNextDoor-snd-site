# frozen_string_literal: true

module Users
  class StoragesController < ApplicationController
    def new
      build_storage
      authorize_resource
    end

    def create
      build_storage
      authorize_resource
      save_storage
    end

    def edit
      load_storage

      redirect_to new_user_storage_path unless @storage.edit_status.starts_with?('update')

      load_booked_booking_slots
      authorize_resource
      switch_to_edit_promotion
    end

    def update
      load_storage
      authorize_resource
      update_storage
    end

    private

    def storage_params
      if params.dig('storage', 'space_attributes', 'dates').is_a? Array
        params[:storage][:space_attributes][:dates] = params[:storage][:space_attributes][:dates].join('; ')
      end

      if params.dig('storage', 'space_attributes', 'discount_code').present?
        params[:storage][:space_attributes][:discount_code] = params[:storage][:space_attributes][:discount_code].to_i
      end

      params.require(:storage).permit(
        :checkin_time,
        :category, :other_rules,
        :accepted_snd_rules,
        features: [], facilities: [], rules: [],
        space_attributes: [
          :id, :name, :description, :dates, :discount_code, :auto_extend_slot,
          :govid_required, :daily_price, :rent_payout_type, :minimum_rent_days,
          :area, :height, :property,
          address_attributes: %i[country city area street_address unit postal_code],
          images_attributes: %i[id description _destroy]
        ]
      )
    end

    def storage_scope
      Storage::Form.where(user: current_user)
    end

    def save_storage
      if params[:back]
        @storage.prev_step
        @storage.save!(validate: false)
        redirect_to new_user_storage_path
      elsif @storage.update(storage_params)
        @storage.next_step!
        redirect_to(@storage.pending? ? well_done_user_spaces_path(id: @storage.space.id) : new_user_storage_path)
      else
        render :new
      end
    end

    def update_storage
      if params[:back]
        @storage.prev_step
        @storage.save!(validate: false)
        redirect_to edit_user_storage_path(@storage)
      elsif @storage.update(storage_params)
        @storage.next_step!
        if @storage.update?
          redirect_to user_spaces_path(identity: :host)
        else
          redirect_to edit_user_storage_path(@storage)
        end
      else
        render :edit
      end
    end

    def build_storage
      @storage ||= (storage_scope.draft.last || storage_scope.build).becomes_form
      @storage.build_space(user: @storage.user) if @storage.space.blank?
    end

    def switch_to_edit_promotion
      return if params[:edit_promotion].nil?

      @storage.edit_promotion!
    end

    def load_storage
      @storage ||= storage_scope.find(params[:id]).becomes_form
    end

    def load_booked_booking_slots
      return unless @storage.update_calendar?

      @booked_booking_slots ||= @storage.space.booking_slots.booked.between(Time.zone.now..Float::INFINITY)
    end
  end
end
