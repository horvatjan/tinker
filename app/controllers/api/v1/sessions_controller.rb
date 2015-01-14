module Api
  module V1
    class API::V1::SessionsController < Devise::RegistrationsController
      include Api::V1::Concerns::Response

      prepend_before_filter :require_no_authentication, :only => [:create ]
      skip_before_filter :verify_authenticity_token

      def create
        build_resource
        user = User.find_for_database_authentication(
          email: params[:user][:email]
        )
        return error_response('User with this email does not exist', 101) unless user


        if user.valid_password?(params[:user][:password])

          return error_response('Your account has not been activated yet', 103) if user.active == 0

          if params[:user][:apns_token].present?
            unless ApnsToken.where(user_id: user.id, token: params[:user][:apns_token]).present?
              if ApnsToken.where(token: params[:user][:apns_token]).present?
                ApnsToken.destroy_all(:token => params[:user][:apns_token])
              end
              ApnsToken.create(user_id: user.id, token: params[:user][:apns_token])
            end
          end

          sign_in("user", user)
          success_response(
            Jbuilder.encode do |j|
              j.auth_token user.authentication_token
            end
          )
        else
          error_response('Email and password do not match', 102)
        end
      end

      def destroy
        sign_out(resource_name)
      end

    end
  end
end
