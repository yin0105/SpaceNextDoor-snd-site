# frozen_string_literal: true

# Mailer proxy to send devise emails in the background
require_dependency 'users_mailer'

class DeviseBackgrounder
  def self.confirmation_instructions(record, token, opts = {})
    new(:confirmation_instructions, record, token, opts)
  end

  def self.reset_password_instructions(record, token, opts = {})
    new(:reset_password_instructions, record, token, opts)
  end

  def self.password_change(record, opts = {})
    new(:password_change, record, nil, opts)
  end

  def self.unlock_instructions(record, token, opts = {})
    new(:unlock_instructions, record, token, opts)
  end

  def initialize(method, record, token, opts = {})
    @args = []
    @args << method
    @args << record
    @args << token if token.present?
    @args << opts
  end

  def deliver
    # You need to hardcode the class of the Devise mailer that you
    # actually want to use. The default is Devise::Mailer.
    UsersMailer.delay.send(*@args)
  end
end
