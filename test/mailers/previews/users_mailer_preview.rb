# frozen_string_literal: true

class UsersMailerPreview < ActionMailer::Preview
  def sign_up_success
    UsersMailer.sign_up_success(User.first)
  end
end
