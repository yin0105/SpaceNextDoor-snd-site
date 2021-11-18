# frozen_string_literal: true

ActiveAdmin.register Order, as: 'Booking' do
  menu priority: 3

  actions :index, :show, :update, :edit

  permit_params :damage_fee, :note, :add_fee, :reasons_for_adjustment

  member_action :revoke, method: :delete do
    OrderRevokeService.new(resource).start!
    create_action_log(status: :succeed)
    redirect_to admin_bookings_path
  end

  member_action :cancel, method: :delete do
    OrderCancelService.new(resource).start!
    create_action_log(status: :succeed)
    redirect_to admin_bookings_path
  end

  member_action :full_refund, method: :delete do
    OrderFullRefundService.new(resource).start!
    create_action_log(status: :succeed)
    redirect_to admin_bookings_path
  end

  member_action :review, method: :put do
    OrderReviewService.new(resource).start!
    create_action_log(status: :succeed)
    redirect_to admin_bookings_path
  end

  member_action :transform_long_lease, method: :put do
    TransformLongLeaseService.new(resource, 'admin').start!
    create_action_log(status: :succeed)
    redirect_to request.referer + "#order_#{resource.id}", flash: { notice: 'Transform long lease success!' }
  end

  member_action :cancel_long_lease, method: :delete do
    CancelLongLeaseService.new(resource, Date.parse(params[:early_check_out])).start!
    create_action_log(status: :succeed)
    flash[:notice] = 'Long lease cancelled'
    head :ok
  end

  controller do
    helper OrdersHelper
    helper ActiveAdmin::ViewsHelper
    include AdminLog

    rescue_from(OrderFullRefundService::PaymentUncompletedError) { redirect_to admin_bookings_path, flash: { error: 'Order has uncompleted payment.' } }
    rescue_from(OrderFullRefundService::NotFullRefundableError) { redirect_to admin_bookings_path, flash: { error: 'Order has cancelled already.' } }
    rescue_from(OrderCancelService::PaymentUncompletedError) { redirect_to admin_bookings_path, flash: { error: 'Order has uncompleted payment.' } }
    rescue_from(OrderCancelService::PrecancelError) { redirect_to admin_bookings_path, flash: { error: 'Service period not yet started.' } }
    rescue_from(OrderReviewService::NotReviewableError) { redirect_to admin_bookings_path, flash: { error: 'This action required review note.' } }

    def csv_filename
      "Bookings-#{Time.zone.today}.csv"
    end

    def update
      super do |success_response, fail_response|
        if success_response.present?
          create_action_log(status: :succeed)
        elsif fail_response.present?
          create_action_log(status: :failed)
        end
      end
    end
  end

  filter :id
  filter :start_at
  filter :end_at
  filter :created_at
  filter :long_term_cancelled_at, label: 'Long-term order terminate at'

  scope :all, default: true
  scope :active
  scope :completed
  scope :reviewed
  scope :cancelled
  scope :early_ended
  scope :pending

  includes %i[guest host space]

  index download_links: [:csv] do
    selectable_column
    id_column
    column :type
    column('Space Name') { |order| link_to order.space.name, space_path(order.space) }
    column :guest
    column :host
    column('Promotion') { |order| display_promotion(order) }
    column(safe_join(['Payment', '<br>'.html_safe, 'Cycle'])) do |order|
      format('%<remain_cycle>d/%<total_cycle>d', remain_cycle: order.remain_payment_cycle,
                                                 total_cycle: order.total_payment_cycle)
    end
    column(safe_join(['Total Storage', '<br>'.html_safe, 'Days'])) { |order| total_storage_days(order) }
    column('Transformed') do |order|
      if order.transform_long_lease_by?
        status_tag I18n.t("active_admin.order.#{order.transform_long_lease_by?}"), class: 'yes'
      else
        status_tag I18n.t("active_admin.order.#{order.transform_long_lease_by?}")
      end
    end
    column('Transform by') do |order|
      I18n.t("active_admin.order.#{order.transform_long_lease_by}") if order.transform_long_lease_by?
    end
    column(:status) do |order|
      if order.cancellation_notice_given?
        status_tag 'Notice Given'
      else
        status_tag order.status
      end
    end
    column('Notice Given') { |order| order.cancelled_at if order.long_term? }
    column(safe_join(['End Date /', '<br>'.html_safe, 'Early End Date'])) { |order| order.long_term? ? order.long_term_cancelled_at : order.end_at }
    column do |order|
      if order.long_term_cancelled_at.nil?
        link_to 'Cancel long term lease', '#', class: 'cancel-long-term-admin', data: { request_path: cancel_long_lease_admin_booking_path(order) }
      end
    end
    column do |order|
      if TransformLongLeaseService.new(order, 'admin').transformable_long_term?
        link_to 'Transform Long Lease', transform_long_lease_admin_booking_path(order), method: :put, data: { confirm: 'It will payment after confirmation, Are you sure?' }
      end
    end
    column do |order|
      if order.reviewable_by_admin?
        link_to 'Mark Reviewed', review_admin_booking_path(order), method: :put
      elsif order.cancellable_by_admin?
        link_to 'Cancel', cancel_admin_booking_path(order), method: :delete, data: { confirm: 'Are you sure?' }
      elsif order.pending?
        link_to 'Revoke', revoke_admin_booking_path(order), method: :delete, data: { confirm: 'Are you sure?' }
      end
    end
    column do |order|
      if order.full_refundable_by_admin?
        link_to 'Full Refund', full_refund_admin_booking_path(order), method: :delete, data: { confirm: 'Are you sure to full refund it?' }
      end
    end
    actions
  end

  csv do
    column :id
    column :type
    column('Space Name') { |order| order.space.name }
    column(:guest) { |order| order.guest.name }
    column(:host) { |order| order.host.name }
    column('Payment Cycle') do |order|
      format('%<remain_cycle>d/%<total_cycle>d', remain_cycle: order.remain_payment_cycle,
                                                 total_cycle: order.total_payment_cycle)
    end
    column('Total Storage Days') { |order| total_storage_days(order) }
    column(:status) do |order|
      if order.cancellation_notice_given?
        'Notice Given'
      else
        order.status
      end
    end
    column('Notice Given') do |order|
      I18n.l(order.cancelled_at, format: :active_admin_date) if order.long_term? && order.cancelled_at.present?
    end
    column('End Date / Early End Date') do |order|
      if order.long_term? && order.long_term_cancelled_at.present?
        I18n.l(order.long_term_cancelled_at, format: :active_admin_date)
      elsif order.end_at.present?
        I18n.l(order.end_at, format: :active_admin_date)
      end
    end
  end

  show do
    attributes_table do
      row :id
      row :type

      row 'total payments' do |order|
        order.payments.valid.count
      end

      row 'Total Storage Days' do |order|
        total_storage_days(order)
      end

      row :price do |order|
        order.price.format(with_currency: true)
      end

      row :host
      row :guest
      row :space

      row 'Insurance' do |order|
        if order.insurance_type.nil?
          'Not booked yet.'
        else
          [
            display_insurance(current_insurance_type(order)),
            display_renewal_insurance(order)
          ].join(' ')
        end
      end

      row :status do |order|
        if order.cancellation_notice_given?
          'notice given'
        else
          order.status
        end
      end

      row :start_at
      row :end_at
      row 'Early End At', &:long_term_cancelled_at

      row :damage_fee do |order|
        order.damage_fee&.to_money&.format(with_currency: true)
      end
      row :note
      row('Promotion') { |order| display_promotion(order) }
      row :rent_payout_type do |order|
        I18n.t("active_admin.order.rent_payout_type.#{order.rent_payout_type}")
      end
    end

    panel 'Transactions' do
      table_for resource.payments.valid do
        column :identity
        column(:amount) { |payment| payment.amount.format }
        column(:rent_to_host) { |payment| payment.host_rent.format }
        column('Guest Insurance') { |payment| payment.premium.format }
        column(:guest_service_fee) { |payment| payment.guest_service_fee.format }
        column(:host_service_fee) { |payment| payment.host_service_fee.format }
        column(:start_at) do |payment|
          payment&.service_start_at
        end
        column(:end_at) do |payment|
          early_end_msg = payment.refund_due? ? " ( Early End #{payment.order.long_term_cancelled_at.strftime('%d %b')} )" : ''
          I18n.l(payment.service_end_at, format: :active_admin_date) + early_end_msg
        end
        column(:status) { |payment| status_tag payment.status }
      end
    end
  end

  form do |_|
    inputs 'Review', class: 'inputs total-refund-calculator' do
      div class: 'input' do
        div class: 'input' do
          span 'Guest'
          span link_to resource.guest.dashboard_display_name.to_s, admin_user_path(resource.guest)
        end
        para class: 'input' do
          link_to "Order ##{resource.id}", admin_booking_path(resource)
        end
        para class: 'input' do
          span 'Guest Deposit Refund', class: 'title'
          if resource.finished?
            span resource.deposit.to_s, class: 'total-refund-calculator__deposit content'
          else
            span '0', class: 'total-refund-calculator__deposit content'
          end
        end
        para class: 'input' do
          span 'Refund Amount (Rent & Service Fee)', class: 'title'
          if resource.refunds.present?
            span resource.refunds.last.amount.to_s, class: 'total-refund-calculator__refund content'
          else
            span '0', class: 'total-refund-calculator__refund content'
          end
        end

        if resource.may_review?
          div class: 'input' do
            span 'Adjustments (Damage Fee)', class: 'title'
            input :damage_fee, label: false, input_html: { class: 'content' }
          end
          div class: 'input' do
            span 'Reasons for Adjustments (Damage Fee)', class: 'title'
            input :note, label: false, input_html: { class: 'content' }
          end
        elsif resource.reviewed?
          para 'Reviewed', class: 'input text-danger font-weight-bold'
          div class: 'input' do
            span 'Adjustments (Damage Fee)', class: 'title'
            input :damage_fee, label: false, input_html: { class: 'content', disabled: true }
          end
          div class: 'input' do
            span 'Reasons for Adjustments (Damage Fee)', class: 'title'
            input :note, label: false, input_html: { class: 'content', disabled: true }
          end
        end

        if resource.refunds.present? && resource.reasons_for_adjustment.blank?
          div class: 'input' do
            span 'Adjustments (Additional Fee)', class: 'title'
            input :add_fee, label: false, input_html: { class: 'content' }
          end
          div class: 'input' do
            span 'Reasons for Adjustments (Additional Fee)', class: 'title'
            input :reasons_for_adjustment, label: false, input_html: { class: 'content' }
          end
        elsif resource.refunds.present?
          para 'Already edited!', class: 'input'
          div class: 'input' do
            span 'Adjustments (Additional Fee)', class: 'title'
            input :add_fee, label: false, input_html: { class: 'content', disabled: true }
          end
          div class: 'input' do
            span 'Reasons for Adjustments (Additional Fee)', class: 'title'
            input :reasons_for_adjustment, label: false, input_html: { class: 'content', disabled: true }
          end
        end

        para class: 'input' do
          span 'Total Refund', class: 'title'
          span '', class: 'total-refund-calculator__total content'
        end
      end
    end

    actions
  end
end
