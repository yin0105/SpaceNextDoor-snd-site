# frozen_string_literal: true

require './lib/insurance'

namespace :spaces do
  desc 'Update orders insurance attributes if space insurance enable'
  task 'setup_orders_insurance' => [:environment] do
    puts 'Process start!'
    puts '======'

    # Setup reject orders:[133, 205, 350]
    # https://git.5xruby.com/snd/SND/-/issues/702

    if Rails.env.production?
      puts 'Setup reject orders:[133, 205, 350]'
      reject_orders = [133, 205, 350]
      orders = Order.where(id: reject_orders)

      orders.each do |order|
        order.update(insurance_lock: true)
      end
    end

    puts 'Setup orders insurance:'
    spaces = Space.activated.where(insurance_enable: true).order(id: :asc)

    spaces.each do |space|
      puts "Check orders of space ##{space.id}:"

      orders = space.orders.valid.includes(:host, :guest).where(status: %w[pending active])

      if orders.present?
        orders.each do |order|
          puts "Check order ##{order.id}:"
          if order.insurance_type.nil?
            if order.can_change_insurance?
              puts "Update orders ##{order.id} and send notify"
              ChangeOrderInsuranceService.new(order, nil).start!
            elsif order.insurance_lock?
              puts "Order ##{order.id} is reject insurance order"
            else
              puts "Order ##{order.id} without payment schedule, escape changed"
            end
          else
            puts "Order ##{order.id} insurance already existed"
          end
        end
      else
        puts 'This space not existed pending orders or active orders'
      end
      puts "Check space ##{space.id} completed!"
      puts '======'
    end

    puts 'Update orders insurance process completed!'
  end
end
