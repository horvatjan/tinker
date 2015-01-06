module Api
  module V1
    class API::V1::UsersController < ApplicationController
      include Api::V1::Concerns::Response

      def index
        user = User.where(authentication_token: request.headers[:token])
        return error_response('User does not exist', 101) unless user.present?
        return error_response('Token has expired', 102) unless (Time.now <= user.first.token_expiration ? true : false)

        users = User.select("id, name, email").where('name LIKE ?', "%#{params[:keyword]}%").limit(50)
        success_response(users)
      end

    end
  end
end
