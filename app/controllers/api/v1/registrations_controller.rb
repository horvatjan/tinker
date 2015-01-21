module Api
  module V1
    class API::V1::RegistrationsController < ApiController
      include Api::V1::Concerns::Response
      skip_before_filter :verify_authenticity_token

      def create
        return error_response('Name is requred', 103) if user_params[:name].blank?

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
          #binding.pry
          if user.errors.messages[:password].present?
            message = 'Password ' + user.errors.messages[:password].first
            code = 103
          else
            message = 'Email ' + user.errors.messages[:email].first
            code = (user.errors.messages[:email].first == "can't be blank" ? 101 : 102)
          end
          error_response(message, code)
        end
      end

      def fb_login

        require 'uri'

            #url = "https://graph.facebook.com/me?access_token="
              #begin
                #content = open(url + params[:user][:access_token])
              #rescue OpenURI::HTTPError #with this I handle if the access token is not ok
                #return render :json => {:error => "not_good_access_token" }
              #end


          #user_text = URI.escape(user_text)
          url = "https://graph.facebook.com/me?access_token=#{params[:user][:access_token]}"
          result = open(url).read

        binding.pry
      end

      def confirm_email
        if User.where(email_confirmation_code: params[:id]).present?
          User.where(email_confirmation_code: params[:id]).update_all(active: 1)
          @text = 'Your email address has been confirmed.'
        else
          @text = 'Problems with account activation. Please, try again.'
        end
       render "registrations/confirm_email"
      end
    end
  end
end
