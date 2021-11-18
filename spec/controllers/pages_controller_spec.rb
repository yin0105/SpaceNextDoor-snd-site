# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PagesController, type: :controller do
  it 'GET #about' do
    get :about
    expect(response).to have_http_status(:success)
  end

  it 'GET #contact' do
    get :contact
    expect(response).to have_http_status(:success)
  end

  it 'GET #tax_and_law' do
    get :tax_and_law
    expect(response).to have_http_status(:success)
  end

  it 'GET #become_host' do
    get :become_host
    expect(response).to have_http_status(:success)
  end

  it 'GET #ip_policy' do
    get :ip_policy
    expect(response).to have_http_status(:success)
  end

  it 'GET #guest_policy' do
    get :guest_policy
    expect(response).to have_http_status(:success)
  end

  it 'GET #host_policy' do
    get :host_policy
    expect(response).to have_http_status(:success)
  end

  it 'GET #host_standard' do
    get :host_standard
    expect(response).to have_http_status(:success)
  end
end
