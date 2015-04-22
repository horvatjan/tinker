module Api
  module V1
    class API::V1::TinksController < ApplicationController
      include Api::V1::Concerns::Response
      include Api::V1::Concerns::Push

      def index
        auth_user and return

        user = User.where(authentication_token: request.headers[:token])
        tinks = Tink.where(recipient_id: user.first.id, read: 0).select("id, user_id, recipient_id, read, color, created_at, text").order(created_at: :desc)
        result = []
        tinks.each do |tink|
          sending_user = User.where(id: tink.user_id).first
          res = {sender_name: sending_user.name, sender_id: sending_user.id, tink_id: tink.id, read: tink.read, created_at: tink.created_at.strftime("%FT%T%:z"), color: tink.color, text: tink.text}
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
        text = "#{user.first.name} is thinking of you."
        Tink.create(user_id: user.first.id, recipient_id: params[:tink][:recipient_id], read: 0, color: color, text: text)

        ApnsToken.where(user_id: params[:tink][:recipient_id]).each do |t|
          send_push_notification(t.token, params[:tink][:recipient_id], text)
        end

        success_response(Tink.where(id: Tink.last.id).select("user_id, recipient_id, read, text").first)
      end

      def destroy
        auth_user and return

        user = User.where(authentication_token: request.headers[:token])
        tink = Tink.where(id: params[:id], recipient_id: user.first.id).first

        return error_response('Recipient does not own that tink.', 103) if tink.blank?

        tink.update(read: "1")
      end
    end
  end
end
