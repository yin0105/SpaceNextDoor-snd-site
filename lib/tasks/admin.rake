# frozen_string_literal: true

require 'securerandom'

namespace :admin do
  desc 'Create new admin user'
  task :create, %i[email password] => [:environment] do |_, args|
    raise 'No email specified!' if args[:email].nil?

    password = args[:password] || SecureRandom.hex(10)
    Admin.create!(email: args[:email], password: password)
    puts '======'
    puts 'New admin created.'
    puts "Email: #{args[:email]}"
    puts "Password: #{password}"
    puts '======'
  end
end
