module Api
  module V1
    class API::V1::RegistrationsController < ApiController
      include Api::V1::Concerns::Response
      skip_before_filter :verify_authenticity_token

      def create
        return error_response('Name is requred', 103) if user_params[:name].blank?
        return error_response('Password is requred', 104) if user_params[:password].blank?

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

          email_confirmation_code = rand(36**20).to_s(36)
          User.where(id: User.last.id).update_all(email_confirmation_code: email_confirmation_code)
          UserMailer.emailconfirmation(user, email_confirmation_code)

          # success_response(
          #   Jbuilder.encode do |j|
          #     j.auth_token user.authentication_token
          #   end
          # )
        else
          if user.errors.messages[:password].present?
            message = 'Password ' + user.errors.messages[:password].first
            code = 105
          else
            message = 'Email ' + user.errors.messages[:email].first
            code = (user.errors.messages[:email].first == "can't be blank" ? 101 : 102)
          end
          error_response(message, code)
        end
      end

      def fb_connect
        return error_response('Access token is requred', 101) if params[:user][:access_token].blank?

        response = HTTParty.get("https://graph.facebook.com/me?access_token=#{params[:user][:access_token]}")

        return error_response('Access token is invalid', 102) if response["error"].present?

        existing_user = User.where(email: response["email"]).first

        if existing_user.present?
          User.where(email: response["email"]).update_all(fbid: response["id"], active: 1, sign_in_count: (existing_user.sign_in_count + 1), current_sign_in_at: Time.now, last_sign_in_at: Time.now, current_sign_in_ip: request.remote_ip, last_sign_in_ip:request.remote_ip)
          user = existing_user
        else
          user = User.create(fbid: response["id"], email: response["email"], name: response["name"], active: 1, password: Passgen::generate(:pronounceable => true, :uppercase => false, :digits_after => 3), sign_in_count: 1, current_sign_in_at: Time.now, last_sign_in_at: Time.now, current_sign_in_ip: request.remote_ip, last_sign_in_ip:request.remote_ip)
        end

        if params[:user][:apns_token].present?
          unless ApnsToken.where(user_id: user.id, token: params[:user][:apns_token]).present?
            if ApnsToken.where(token: params[:user][:apns_token]).present?
              ApnsToken.destroy_all(:token => params[:user][:apns_token])
            end
            ApnsToken.create(user_id: user.id, token: params[:user][:apns_token])
          end
        end

        success_response({auth_token: user.authentication_token, name: user.name})
      end
    end
  end
end
