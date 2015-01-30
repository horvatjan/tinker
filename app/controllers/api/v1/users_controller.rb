module Api
  module V1
    class API::V1::UsersController < ApplicationController
      include Api::V1::Concerns::Response

      def index
        auth_user and return

        users = User.select("id AS user_id, name, email").where('name LIKE ?', "%#{params[:keyword]}%").limit(50)
        result = {users: users}
        success_response(result)
      end

      def edit
        auth_user and return

        return error_response('New name is requred', 103) unless params[:user][:name].present?

        User.where(authentication_token: request.headers[:token]).update_all(name: params[:user][:name])
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
