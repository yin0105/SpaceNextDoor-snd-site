# frozen_string_literal: true

class Order
  module HasAASMStatus
    extend ActiveSupport::Concern

    included do
      include AASM

      aasm column: :status, enum: true, no_direct_assignment: true do
        state :pending, initial: true
        state :active, :cancelled, :completed, :reviewed, :early_ended, :full_refunded

        event :activate, after_commit: %i[notify_after_activate mark_booking_slots_booked send_system_message] do
          transitions from: :pending, to: :active
          before { perform_after_activate }
        end

        event :complete, after_commit: :notify_after_complete do
          transitions from: :active, to: :completed
          after { perform_after_complete }
        end

        event :cancel, after: :perform_after_cancel do
          transitions from: :active, to: :cancelled
          before { assign_attributes(cancelled_at: Time.zone.now) }
        end

        event :full_refunded, after: :perform_after_full_refunded do
          transitions from: :active, to: :full_refunded
          before { assign_attributes(cancelled_at: Time.zone.now) }
        end

        event :early_end, after: :perform_after_early_end do
          transitions from: :active, to: :early_ended
        end

        event :review, after: :perform_after_review do
          transitions from: :completed, to: :reviewed
          transitions from: :early_ended, to: :reviewed
        end

        event :revoke do
          transitions from: :pending, to: :cancelled
          before { assign_attributes(cancelled_at: Time.zone.now) }
        end
      end

      private

      def perform_after_activate
        self.channel = Channel.where(space: space, host: host, guest: guest).first_or_create!
      end

      def mark_booking_slots_booked
        book_slots
      end

      def notify_after_activate
        send_notification(action: :activating, resource: self, klass: :order)
      end

      def send_system_message
        return if create_new_channels_message?(channel)

        channel.create_system_message(start_at, end_at)
      end

      def perform_after_complete
        guest.create_ratings(self)
        host.create_ratings(self)
      end

      def notify_after_complete
        send_notification(action: :guest, resource: self, klass: :rating)
        send_notification(action: :host, resource: self, klass: :rating)
      end

      def perform_after_review
        OrderCloseService.new(self, :review).execute
      end

      def perform_after_cancel
        OrderCloseService.new(self, :cancel).execute
        unbook_slots
      end

      def perform_after_early_end
        OrderCloseService.new(self, :early_end).execute if refund_due?
        unbook_slots
      end

      def perform_after_full_refunded
        OrderCloseService.new(self, :full_refund).execute
        unbook_slots
      end

      def create_new_channels_message?(channel)
        channel.messages.any? && !(same_record? self, channel)
      end

      def same_record?(new_order, before_channel)
        new_order.space_id == before_channel.space_id &&
          new_order.host_id == before_channel.host_id &&
          new_order.guest_id == before_channel.guest_id
      end
    end
  end
end
