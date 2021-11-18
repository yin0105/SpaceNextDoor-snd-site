# frozen_string_literal: true

module HostEditInfoFlow
  extend ActiveSupport::Concern

  def host_next_edit_flow_path
    return edit_user_registration_path(identity: 'host') if current_user.address.id.nil?
    return verification_path(identity: 'host') if current_user.phone.nil?
    return bank_account_path(identity: 'host') if current_user.bank_account.nil?
    return host_contact_path(identity: 'host') if current_user.as_host.contact.nil?

    user_spaces_path
  end

  def is_host?(identity)
    identity == 'host'
  end
end
