# frozen_string_literal: true

class YearlyDatepickerInput < SimpleForm::Inputs::Base
  def input(_wrapper_options = nil)
    template.content_tag :div, class: 'clearfix py-4' do
      12.times do |i|
        range_start = i.months.from_now.beginning_of_month
        range_end = i.months.from_now.end_of_month
        range_start = Time.zone.today if range_start < Time.zone.today

        template.concat month_calender(range_start: range_start, range_end: range_end)
      end
    end
  end

  def month_calender(range_start:, range_end:)
    enabled_dates = (range_start.to_datetime..range_end.to_datetime)
                    .map { |d| d.strftime('%Y-%m-%d') } + ['1970-1-1']
    enabled_dates -= options[:disabled_dates] if options[:disabled_dates]

    template.content_tag :div, class: 'w-md-50 w-lg-33' do
      @builder.input :dates, as: :datepicker,
                             mode: :multiple,
                             inline: true,
                             enable: enabled_dates,
                             min_date: range_start.strftime('%Y-%m-%d'),
                             value: options[:value],
                             input_html: {
                               name: "#{@builder.object_name}[#{attribute_name}][]"
                             },
                             label: false
    end
  end
end
