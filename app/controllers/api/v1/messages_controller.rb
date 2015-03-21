module Api
  module V1
    class API::V1::MessagesController < ApplicationController
      include Api::V1::Concerns::Response

      def create
        auth_user and return

        user = User.where(authentication_token: request.headers[:token])

        return error_response('Subject is required', 102) unless params[:subject].present?
        return error_response('Message is required', 103) unless params[:message].present?

        ContactMailer.forward_contact_message([
          email: user.first.email,
          subject: params[:subject],
          message: params[:message]
        ].first)
      end

    end
  end
end
