module Api
  module V1
    class API::V1::FriendsController < ApplicationController
      include Api::V1::Concerns::Response

      def index
        auth_user and return

        user = User.where(authentication_token: request.headers[:token])
        friends = Friend.where(user_id: user.first.id)
        result = []
        friends.each do |friend|
          fr = User.where(id: friend.friend_id).select("id AS user_id, name, email").first
          result.push fr
        end

        frnds = {friends: result}
        success_response(frnds)
      end

      def create
        auth_user and return

        user = User.where(authentication_token: request.headers[:token])

        return error_response('Friend id is required', 103) unless params[:friend_id].present?
        return error_response('User you want to befriend does not exists', 104) if User.where(id: params[:friend_id]).blank?
        return error_response('Can not befriend yourself', 105) if user.first.id == params[:friend_id].to_i
        return error_response('You are already friends with this user', 106) unless Friend.where(user_id: user.first.id, friend_id: params[:friend_id]).blank?

        friend = Friend.create(user_id: user.first.id, friend_id: params[:friend_id])
        result = {user_id: friend[:user_id], friend_id: friend[:friend_id]}

        success_response(result)
      end

      def destroy
        auth_user and return

        user = User.where(authentication_token: request.headers[:token])

        return error_response('Friend id is required', 103) unless params[:id].present?
        return error_response('User does not exists', 104) if User.where(id: params[:id]).blank?
        return error_response('You are not friends with this user to begin with', 105) if Friend.where(user_id: user.first.id, friend_id: params[:id].to_i).blank?

        Friend.where(user_id: user.first.id).where(friend_id: params[:id]).delete_all
      end
    end
  end
end
