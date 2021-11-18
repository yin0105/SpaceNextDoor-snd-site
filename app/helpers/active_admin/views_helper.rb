# frozen_string_literal: true

module ActiveAdmin
  module ViewsHelper
    def total_storage_days(order)
      today = Time.zone.today

      return (order.long_term_cancelled_at - order.start_at).to_i + 1 if order.long_term_ended?
      return (order.end_at - order.start_at).to_i + 1 if order.completed?
      return (today - order.start_at).to_i + 1 if order.active? && today >= order.start_at
    end

    def transaction_period(payout)
      end_time = [payout.payment.service_end_at, payout.order.long_term_cancelled_at || payout.payment.service_end_at].min
      duration = (end_time.to_date - payout.payment.service_start_at.to_date).to_i + 1
      display_duration(payout.payment.service_start_at, end_time, duration)
    end

    def payout_host_period(payout)
      if payout.start_at.present? && payout.end_at.present?
        start_time = payout.start_at
        end_time = payout.end_at
      else
        start_time = payout.payment.service_start_at
        end_time = [payout.payment.service_end_at, payout.order.long_term_cancelled_at || payout.payment.service_end_at].min
      end
      duration = (end_time.to_date - start_time.to_date).to_i + 1
      display_duration(start_time, end_time, duration)
    end

    def date_payable_to_host(payout)
      if payout.end_at.present?
        payout.end_at
      else
        end_time = payout.order.long_term_cancelled_at || payout.payment_service_end_at
        [payout.payment_service_end_at, end_time].min
      end
    end

    def deposit_return_due_date(payout)
      if payout.order.long_term_cancelled_at.present?
        (payout.order.long_term_cancelled_at + 2.weeks)
      else
        (payout.order.end_at + 2.weeks)
      end
    end

    def display_duration(start_time, end_time, duration)
      start_time = I18n.l(start_time, format: :active_admin_short)
      end_time = I18n.l(end_time, format: :active_admin_short)
      "#{start_time} - #{end_time} (#{duration}) "
    end

    def display_promotion(order)
      return 'One Month' if order.discount_code == 'one_month'
      return 'Two Months' if order.discount_code == 'two_months'

      'None'
    end

    def display_renewal_insurance(order)
      return unless order.can_change_insurance? && order.insurance_enable
      return if current_insurance_type(order) == order.insurance_type

      [
        '(',
        display_insurance(order.insurance_type),
        " is w.e.f. #{display_next_service_start_date(order)})"
      ].join(' ')
    end

    def display_insurance_enable(space)
      space.insurance? ? 'Enabled' : 'Disabled'
    end

    def deposit_and_refund_both_paid?(payment)
      refund = payment.payouts.refund.last&.paid?
      deposit = payment.payouts.deposit.last&.paid?
      return true if refund.nil? && deposit == true
      return true if refund == true && deposit.nil?
      return true if refund && deposit

      false
    end

    def display_versions_change(versions)
      return 'No Changes' if versions.blank?

      content_tag :div do
        versions.map.with_index do |version, index|
          concat "\n" if index != 0
          concat "#{version.item_type}##{version.item_id} (#{version.event.titleize})"
          concat content_tag :div, '', class: 'version-changes', data: { info: encrypt_version_info(version.changeset) }
        end
      end
    end

    def encrypt_version_info(data)
      encrypt_keys = ['encrypted_password']

      data.each do |key, _value|
        data[key] = ['*' * 20, '*' * 20] if encrypt_keys.include?(key)
      end
    end

    def display_resource_link(resource_class, id)
      link_to id, active_admin_resource_for(resource_class)&.route_instance_path(id)
    end
  end
end
