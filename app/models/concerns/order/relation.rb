# frozen_string_literal: true

class Order
  module Relation
    extend ActiveSupport::Concern

    included do
      belongs_to :guest, class_name: 'User::Guest'
      belongs_to :host, class_name: 'User::Host'
      belongs_to :space
      belongs_to :channel, optional: true
      has_many :payments
      has_many :late_fee_payments
      has_one :down_payment
      has_one :last_payment
      has_one :service_fee
      has_many :ratings
      has_many :payouts, through: :payments
      has_many :refunds, -> { where(payments: { payouts: { type: :refund } }) }, through: :payments, source: :payouts, class_name: 'Payout'

      delegate :host_rate, to: :service_fee, prefix: true, allow_nil: true
      delegate :guest_rate, to: :service_fee, prefix: true, allow_nil: true
    end
  end
end
