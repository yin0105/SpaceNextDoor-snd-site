# frozen_string_literal: true

class User
  class ParameterSanitizer < Devise::ParameterSanitizer
    def initialize(*)
      super
      permit(:sign_up, keys:
             %i[
               email
               password
               password_confirmation
               first_name
               last_name
               belonging_avatar_id
             ])
      permit(:account_update, keys:
             [
               :email,
               :password,
               :password_confirmation,
               :current_password,
               :first_name,
               :last_name,
               :belonging_avatar_id,
               :gender,
               :birthday,
               :biography,
               address_attributes: %i[country city area street_address unit postal_code]
             ])
    end
  end
end
