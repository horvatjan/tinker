module Api
  module V1
    class API::V1::RegistrationsController < ApiController
      include Api::V1::Concerns::Response
      skip_before_filter :verify_authenticity_token

      def create
        user = User.new(user_params)
        if user.save

          if params[:user][:apns_token].present?
            unless ApnsToken.where(user_id: User.last.id, token: params[:user][:apns_token]).present?
              if ApnsToken.where(token: params[:user][:apns_token]).present?
                ApnsToken.destroy_all(:token => params[:user][:apns_token])
              end
              ApnsToken.create(user_id: User.last.id, token: params[:user][:apns_token])
            end
          end

          success_response(
            Jbuilder.encode do |j|
              j.auth_token user.authentication_token
            end
          )
        else
          error_response(
            'Email ' + user.errors.messages[:email].first,
            (user.errors.messages[:email].first == "can't be blank" ? 101 : 102)
          )
        end
      end
    end
  end
end
