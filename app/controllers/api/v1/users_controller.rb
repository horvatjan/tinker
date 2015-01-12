module Api
  module V1
    class API::V1::UsersController < ApplicationController
      include Api::V1::Concerns::Response

      def index
        auth_user and return

        users = User.select("id, name, email").where('name LIKE ?', "%#{params[:keyword]}%").limit(50)
        success_response(users)
      end

      def edit
        auth_user and return

        return error_response('New name is requred', 103) unless params[:user][:name].present?

        User.where(authentication_token: request.headers[:token]).update_all(name: params[:user][:name])
      end

      def new_password
        require 'bcrypt'

        new_password = Passgen::generate(:pronounceable => true, :uppercase => false, :digits_after => 3)
        encrypted_password = BCrypt::Password.create(new_password)

       User.where(email: params[:user][:email]).update_all(encrypted_password: encrypted_password)

user = User.where(email: params[:user][:email]).first
    @user = user
    binding.pry
    # I am overriding the 'to' default
new_password_email(@user)
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
    end
  end
end
