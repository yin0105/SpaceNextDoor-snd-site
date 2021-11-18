# frozen_string_literal: true

class TransformLongLeaseByGuestForm < TransformLongLeaseForm
  attr_accessor :term

  validates :term, acceptance: true

  def attributes
    { term: @term }
  end

  def error_messages
    @error_messages = I18n.t('custom_error_msgs.transform_long_lease_by_guest_form.term_blank_full') if errors.messages[:term].present?
  end
end
