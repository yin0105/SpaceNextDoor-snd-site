# frozen_string_literal: true

class PagesController < ApplicationController
  skip_before_action :authenticate_user!
  skip_authorization_check

  def why_choose_us; end

  def how_it_work; end

  def need_more_storage; end

  def types_of_storage; end

  def about; end

  def contact; end

  def tax_and_law; end

  def become_host; end

  def privacy; end

  def ip_policy; end

  def guest_policy; end

  def host_policy; end

  def host_standard; end

  def snd_rules; end

  def terms_of_service; end

  def terms_and_policies; end

  def signup_success; end

  def insurance_terms
    send_file Rails.root.join('public/insurance_terms.pdf'), filename: 'insurance_terms.pdf', type: 'application/pdf', disposition: 'inline'
  end

  def host_onboarding
    authenticate_user!
  end
end
