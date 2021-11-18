# frozen_string_literal: true

module ActiveAdmin
  module PdfsHelper
    def total_by_field(payments, field)
      payments.reduce(zero_money) { |sum, payment| sum += payment[field] }.format
    end

    def zero_money
      Money.new(0)
    end
  end
end
