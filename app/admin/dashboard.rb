# frozen_string_literal: true

ActiveAdmin.register_page 'Dashboard' do
  menu priority: 1, label: proc { I18n.t('active_admin.dashboard') }

  content title: proc { I18n.t('active_admin.dashboard') } do
    columns do
      column do
        panel 'GUEST Overview' do
          ul do
            li "Total Number of Active Guests: #{User.guests_with_existing_bookings.count}"
            li "Weekly / Monthly Sign Ups: #{User::Guest.joins(:orders).last_week_signed_up.count} / #{User::Guest.joins(:orders).last_month_signed_up.count}"
            li "Weekly / Monthly Move out: #{User::Guest.joins(:orders).last_week_moved_out.count} / #{User::Guest.joins(:orders).last_month_moved_out.count}"
            br
          end
        end
        panel 'HOSTS Overview' do
          ul do
            li "Total Number of Active Hosts: #{User.hosts_with_existing_bookings.count}"
            li "Weekly / Monthly Sign Ups: #{User::Host.joins(:orders).last_week_signed_up.count} / #{User::Host.joins(:orders).last_month_signed_up.count}"
            li "Weekly / Monthly Move out: #{User::Host.joins(:orders).last_week_moved_out.count} / #{User::Host.joins(:orders).last_month_moved_out.count}"
            br
          end
        end
        panel 'Financial Overview' do
          ul do
            li "Monthly revenue: #{humanized_money_with_symbol Payment.monthly_revenue}"
            li "Annual revenue: #{humanized_money_with_symbol Payment.annual_revenue}"
            br
          end
        end
        panel 'Inventory Overview' do
          ul do
            li "Total build-up / occupancy taken up: #{sqm_to_sqft(Space.build_up_area)} / #{sqm_to_sqft(Space.occupied_area)} sqft"
            li "Total available space: #{sqm_to_sqft(Space.available_area)} sqft"
          end
          br
        end
        panel 'Total number of units available & booked by area' do
          ul do
            Address.areas.each do |area|
              li "#{area}: #{Space.available_by_area(area)} available / #{Space.booked_by_area(area)} booked"
            end
          end
          br
        end
      end
    end

    #     panel "Info" do
    #       para "Welcome to ActiveAdmin."
    #     end
    #   end
    # end
  end
end

def sqm_to_sqft(area)
  (area * 10.7639).round
end
