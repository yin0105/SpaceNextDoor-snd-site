# frozen_string_literal: true

class FindOutMoresController < ApplicationController
  skip_before_action :authenticate_user!
  skip_authorization_check

  def new
    @locations = Regions::AREA_CODES.keys.reject(&:blank?).unshift('No preference')
    @request = FindOutRequest.new
    set_identity
    load_booking_input_date
    session[:last_visit_space_id] = params[:space_id]
  end

  def create
    @locations = Regions::AREA_CODES.keys.reject(&:blank?).unshift('No preference')
    @request = FindOutRequest.new(find_out_params)
    connect_user
    connect_space
    check_find_out_request
  end

  def thank_you; end

  def host_submitted; end

  protected

  def find_out_params
    attributes = params.require(:find_out_request).permit(
      :name, :phone, :email, :location, :start_at, :end_at, :description, :size, :address, :postal_code, :identity
    )
    attributes[:identity] = :guest if attributes[:identity].present? && (FindOutRequest::IDENTITIES.keys.exclude? attributes[:identity].to_sym)
    attributes
  end

  def set_identity
    identity = params.fetch(:identity, :guest).to_sym == :host ? :host : :guest
    @request.identity = identity
  end

  def load_booking_input_date
    @request.start_at = params[:start_at]
    @request.end_at = params[:end_at]
  end

  def connect_user
    return @request.user = current_user if user_signed_in?

    user = User.find_by(email: @request.email)
    @request.user = user unless user.nil?
  end

  def connect_space
    @request.space = Space.find_by(id: session[:last_visit_space_id])
  end

  def check_find_out_request
    return render_new_form unless @request.valid? && recaptcha_valid?

    @request.save
    redirect_to url_for(action: :thank_you)
  end

  def render_new_form
    @show_recaptcha_v2_checkbox = true unless recaptcha_v3_success?
    render :new
  end

  def recaptcha_valid?
    return true if recaptcha_v3_success? || recaptcha_v2_success?

    false
  end

  def recaptcha_v3_success?
    @recaptcha_v3_success = verify_recaptcha(action: 'new_enquiry', minimum_score: 0.5)
    @recaptcha_v3_success
  end

  def recaptcha_v2_success?
    @checkbox_success = verify_recaptcha secret_key: Settings.google.recaptcha_v2_secret_key
    @checkbox_success
  end
end
