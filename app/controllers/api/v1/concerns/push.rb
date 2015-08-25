module Api::V1::Concerns::Push
  extend ActiveSupport::Concern
    require 'houston'

    def send_push_notification(apn_token, recipient_id, text)
      certificate = File.read("#{Rails.root}/lib/apns-#{Rails.env}.pem")
      connection = Houston::Connection.new((Rails.env == "production" ? Houston::APPLE_PRODUCTION_GATEWAY_URI : Houston::APPLE_DEVELOPMENT_GATEWAY_URI), certificate, ENV["CERTIFICATE_PASSPHRASE"])
      connection.open

      notification = Houston::Notification.new(device: apn_token)
      notification.alert = text
      notification.badge = Tink.where(recipient_id: recipient_id, read: 0).count
      notification.sound = "alertsound.aiff"
      notification.content_available = false
      connection.write(notification.message)

      connection.close
    end

    def get_color(recipient_id)
      tink = Tink.where(recipient_id: recipient_id).select('color').last
      if tink.present?
        ([*1..6] - [tink.color]).sample
      else
        ([*1..6]).sample
      end
    end
end
