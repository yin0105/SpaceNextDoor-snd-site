# frozen_string_literal: true

class SmsService
  def initialize
    @client = Twilio::REST::Client.new
  end

  def send_out(to:, body:)
    @client.messages.create(
      messaging_service_sid: Settings.twilio.service_sid,
      to: to,
      body: body
    )
  end
end
