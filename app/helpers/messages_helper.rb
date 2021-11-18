# frozen_string_literal: true

module MessagesHelper
  def message_dialog_extra_style(message)
    return 'target' if message.user != current_user

    ''
  end
end
