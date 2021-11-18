# frozen_string_literal: true

class LastPayment < ActiveType::Record[Payment]
  include ActiveTypeInheritable

  default_scope -> { unscope(:order).order(serial: :desc, id: :desc) }

  def completed?
    success? || resolved?
  end
end
