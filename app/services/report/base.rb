# frozen_string_literal: true

module Report
  class Base
    def initialize(args = {})
      @year = args[:start_year]
      @month = args[:start_month]
      @type = args[:type]
      @export_type = args[:export_type]
    end

    def pdf
      WickedPdf.new.pdf_from_string(
        ApplicationController.new.render_to_string(
          "/admin/financial_reports/#{@type}.pdf",
          layout: 'default.pdf',
          margin: { bottom: 30 },
          locals: { payments: pdf_content, start_date: start_date }
        ),
        orientation: 'Landscape',
        page_width: '2000',
        header: {
          content: ApplicationController.new.render_to_string(
            '/admin/financial_reports/header.pdf',
            layout: 'default.pdf',
            locals: { type: @type }
          )
        },
        footer: {
          content: ApplicationController.new.render_to_string(
            '/admin/financial_reports/footer.pdf',
            layout: 'default.pdf'
          )
        }
      )
    end

    def csv
      CSV.generate(encoding: 'UTF-8') do |csv|
        csv << csv_header
        csv_content.each do |data|
          csv << data
        end
        csv << []
        csv << ['Report Explanation']
        I18n.t("report_explanations.#{@type}").each do |content|
          csv << [content]
        end
      end
    end

    private

    def is_snd_id?(id)
      id == 21
    end

    def csv_header
      raise NotImplementedError
    end

    def csv_content
      raise NotImplementedError
    end

    def pdf_content
      raise NotImplementedError
    end

    def find_payments
      raise NotImplementedError
    end

    def start_date
      Date.parse("#{@month} 01, #{@year}")
    end

    def end_date
      start_date.end_of_month
    end

    def zero_money
      Money.new(0)
    end

    def move_out_date(payment)
      if payment.order.long_term?
        payment.order.cancelled_at.nil? ? '' : I18n.l(payment.order.long_term_cancelled_at, format: :mail_date)
      else
        I18n.l(payment.service_end_at, format: :mail_date)
      end
    end

    def payouts_filter_by_type(payouts, type)
      payouts.select { |payout| payout.type == type }
    end
  end
end
