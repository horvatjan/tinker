module Api
  module V1
    class API::V1::TinksController < ApplicationController
      include Api::V1::Concerns::Response
      require 'houston'

      def index
        auth_user and return

        user = User.where(authentication_token: request.headers[:token])
        tinks = Tink.where(recipient_id: user.first.id).select("id, user_id, recipient_id, read, created_at")
        result = []
        tinks.each do |tink|
          sending_user = User.where(id: tink.recipient_id).first
          res = {sender_name: sending_user.name, sender_id: sending_user.id, tink_id: tink.id, read: tink.read, created_at: tink.created_at.strftime("%FT%T%:z")}
          result.push res
        end
        result = {tinks: result}
        success_response(result)
      end

      def create
        auth_user and return

        user = User.where(authentication_token: request.headers[:token])

        return error_response('Recipient id is required', 103) unless params[:tink][:recipient_id].present?
        return error_response('Recipient does not exists', 104) if User.where(id: params[:tink][:recipient_id]).blank?
        return error_response('Recipient has been banned', 105) unless Ban.where(user_id: user.first.id, banned_id: params[:tink][:recipient_id]).empty?

        color = get_color(params[:tink][:recipient_id])
        Tink.create(user_id: user.first.id, recipient_id: params[:tink][:recipient_id], read: 0, color: color)

        ApnsToken.where(user_id: params[:tink][:recipient_id]).each do |t|
          send_push_notification(t.token, user.first.name, params[:tink][:recipient_id])
        end

        success_response(Tink.where(id: Tink.last.id).select("user_id, recipient_id, read, created_at").first)
      end

      def destroy
        auth_user and return

        user = User.where(authentication_token: request.headers[:token])
        tink = Tink.where(id: params[:id], recipient_id: user.first.id).first

        return error_response('Recipient does not own that tink.', 103) if tink.blank?

        tink.update(read: "1")
      end

      private

        def send_push_notification(apn_token, sender_name, recipient_id)
          certificate = File.read("/var/www/projects/tinker/lib/apns-development.pem")
          passphrase = ""
          connection = Houston::Connection.new(Houston::APPLE_DEVELOPMENT_GATEWAY_URI, certificate, passphrase)
          connection.open

          notification = Houston::Notification.new(device: apn_token)
          notification.badge = Tink.where(recipient_id: recipient_id, read: 0).count
          notification.sound = "alertsound.aiff"
          notification.content_available = true
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
  end
end
