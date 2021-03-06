module Api
  module V1
    class API::V1::UsersController < ApplicationController
      include Api::V1::Concerns::Response
      include Api::V1::Concerns::ValidateUsername

      def index
        auth_user and return

        by_name_username = User.select("id, name, email, username").where("registration_status = 2 AND name || username ILIKE ?", "%#{params[:keyword]}%").limit(50)
        by_email = User.select("id, name, email, username").where("registration_status = 2 AND email_visibility = 1 AND email ILIKE ?", "%#{params[:keyword]}%").limit(50)

        response = []
        by_name_username.each do |user|
          response << user
        end

        by_email.each do |user|
          response << user
        end

        response = response.uniq

        result = []
        response.each do |item|
          user = {
            user_id: item.id,
            name: item.name,
            email: item.email,
            username: item.username
          }
          result << user
        end

        success_response({users: result})
      end

      def edit
        auth_user and return

        user = User.find_for_database_authentication(authentication_token: request.headers[:token])

        name = user.name
        if (user.name != params[:user][:name] && params[:user][:name].present?)
          return error_response("Name's length must be between 4 and 24 characters", 104) unless check_name(params[:user][:name])
          name = params[:user][:name]
        end

        username = user.username
        if (user.username != params[:user][:username] && params[:user][:username].present?)
          return error_response('Username is invalid', 102) unless check_username(params[:user][:username])
          return error_response('Username is already in use', 103) unless unique(params[:user][:username])
          username = params[:user][:username]
        end

        email_visibility = user.email_visibility
        if (user.email_visibility != params[:user][:email_visibility] && params[:user][:email_visibility].present?)
          email_visibility = params[:user][:email_visibility]
        end

        registration_status = user.registration_status
        if (user.registration_status != params[:user][:registration_status] && params[:user][:registration_status].present?)
          registration_status = params[:user][:registration_status]
        end

        User.where(authentication_token: request.headers[:token]).update_all(name: name, username: username, email_visibility: email_visibility, registration_status: registration_status)
        success_response(name: name, username: username, email_visibility: email_visibility, registration_status: registration_status)
      end

      def new_password
        require 'bcrypt'

        return error_response('Email address not provided', 101) unless params[:user][:email].present?
        user = User.where(email: params[:user][:email]).first
        return error_response('User with this email address does not exists', 102) if user.blank?
        new_password = Passgen::generate(:pronounceable => true, :uppercase => false, :digits_after => 3)
        encrypted_password = BCrypt::Password.create(new_password)
        User.where(email: params[:user][:email]).update_all(encrypted_password: encrypted_password)
        UserMailer.newpassword(user, new_password)
      end

      def change_password
        require 'bcrypt'
        auth_user and return

        user = User.find_for_database_authentication(authentication_token: request.headers[:token])

        return error_response('Old password is incorrect', 102) unless user.valid_password?(params[:old_password])
        return error_response('New password is too short (6 characters minimum)', 103) unless params[:new_password].length >= 6

        User.where(id: user.id).update_all(
          encrypted_password: BCrypt::Password.create(params[:new_password])
        )
      end

      def resend_confirmation_code
        return error_response('Email address not provided', 101) unless params[:user][:email].present?
        user = User.where(email: params[:user][:email]).first
        return error_response('User with this email address does not exists', 102) if user.blank?

        email_confirmation_code = rand(36**20).to_s(36)
        User.where(id: user.id).update_all(email_confirmation_code: email_confirmation_code, active: 0)
        UserMailer.emailconfirmation(user, email_confirmation_code)
      end

      def ban
        auth_user and return

        user = User.where(authentication_token: request.headers[:token])

        return error_response('Banned user id is required', 103) unless params[:banned_id].present?
        return error_response('Banned user does not exists', 104) if User.where(id: params[:banned_id]).blank?
        return error_response('Can not ban yourself', 105) if user.first.id == params[:banned_id].to_i
        return error_response('You have alredy banned this user', 106) unless Ban.where(user_id: user.first.id, banned_id: params[:banned_id]).blank?

        if params[:ban].to_i == 1
          Ban.create(user_id: user.first.id, banned_id: params[:banned_id])
        else
          Ban.where(user_id: user.first.id).where(banned_id: params[:banned_id]).delete_all
        end
      end

      def check
        auth_user and return
        result = []
        ActiveSupport::JSON.decode(request.body.string)["users"].each do |email|
          result << {'email' => email, 'is_user' => (User.where(email: email).select("email").blank? ? 0 : 1) }
        end
        success_response({"users" => result})
      end
    end
  end
end
