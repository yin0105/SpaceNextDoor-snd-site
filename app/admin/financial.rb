# frozen_string_literal: true

ActiveAdmin.register_page 'Financial Reports' do
  menu priority: 6

  page_action :export, method: :post do
    export_file_flow
  end

  controller do
    rescue_from(ArgumentError) { |e| argument_info_errors(e) }
    rescue_from(NameError) { |e| argument_info_errors(e) }

    def export_file_flow
      file = call_export_service
      if payment_params[:export_type] == 'csv'
        send_data file.encode('UTF-8'), type: 'text/csv; charset=UTF-8;', disposition: "attachment; filename=#{payment_params[:type]}_#{DateTime.now}.csv"
      else
        send_data file, type: 'application/pdf', disposition: "attachment; filename=#{payment_params[:type]}_#{DateTime.now}.pdf"
      end
    end

    private

    def argument_info_errors(err)
      logger.error err.message
      logger.error err.backtrace.join("\n")
      redirect_to admin_financial_reports_path, flash: { error: 'Export file failed, Arguments are incorrect' }
    end

    def payment_params
      params.require(:financial).permit(:start_year, :start_month, :type, :export_type)
    end

    def call_export_service
      service = Report.const_get(payment_params[:type].classify)
      service.new(payment_params).send(payment_params[:export_type])
    end
  end

  content do
    render partial: 'export_form'
  end
end
