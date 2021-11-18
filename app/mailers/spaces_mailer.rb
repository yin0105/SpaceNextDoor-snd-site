# frozen_string_literal: true

class SpacesMailer < ApplicationMailer
  def approval(space)
    @user = space.user
    @space = space
    mail(to: @user.email,
         subject: 'Congratulations! Your listing has been approved!', &WAYS)
  end

  def submission(space)
    @user = space.user
    @space = space
    mail(to: Settings.notification.bcc_list,
         subject: 'New Space Listing', &WAYS)
  end

  def disapproval(space)
    @space = space
    @user = space.user
    mail(to: @user.email,
         subject: 'Your listing has been disapproved!')
  end
end
