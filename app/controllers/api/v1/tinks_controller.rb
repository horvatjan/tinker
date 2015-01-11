module Api
  module V1
    class API::V1::TinksController < ApplicationController
      include Api::V1::Concerns::Response
      require 'houston'

      def index
        auth_user and return

        user = User.where(authentication_token: request.headers[:token])
        tinks = [
          outgoing: Tink.where(user_id: user.first.id),
          incoming: Tink.where(recipient_id: user.first.id)
        ]

        success_response(tinks)
      end

      def create
        auth_user and return

        user = User.where(authentication_token: request.headers[:token])

        return error_response('Recipient id is required', 103) unless params[:tink][:recipient_id].present?
        return error_response('Recipient does not exists', 104) if User.where(id: params[:tink][:recipient_id]).blank?
        return error_response('Recipient has been banned', 105) unless Ban.where(user_id: user.first.id, banned_id: params[:tink][:recipient_id]).empty?

        tink = Tink.create(user_id: user.first.id, recipient_id: params[:tink][:recipient_id], read: 0)

        ApnsToken.where(user_id: params[:tink][:recipient_id]).each do |t|
          send_push_notification(t.token, user.first.name, params[:tink][:recipient_id])
        end

        success_response(tink)
      end

      def destroy
        auth_user and return

        user = User.where(authentication_token: request.headers[:token])
        tink = Tink.where(id: params[:id], recipient_id: user.first.id).first
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
    end
  end
end
