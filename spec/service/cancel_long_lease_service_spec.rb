# frozen_string_literal: true

require 'rails_helper'

describe 'CancelLongLeaseService' do
  describe 'cancel long lease' do
    let(:early_check_out) { Time.zone.today }
    let(:order) { create(:order, :with_payments) }

    before { CancelLongLeaseService.new(order, early_check_out).start! }

    context 'when success' do
      it 'updates long_term_cancelled_at for order' do
        expect(order.reload.long_term_cancelled_at).to eq(early_check_out)
      end

      it 'schedules cancellation' do
        expect(order.schedules.where(event: 'long_lease_end')).not_to be_empty
      end

      it 'sends notifications' do
        have_enqueued_job.on_queue('mailers')
      end
    end
  end
end
