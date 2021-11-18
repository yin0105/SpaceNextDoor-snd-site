# frozen_string_literal: true

class DownPayment < ActiveType::Record[Payment]
  default_scope -> { valid.where(deposit_cents: 1..Float::INFINITY) }
end
