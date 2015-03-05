module Api
  module V1
    class API::V1::FriendsController < ApplicationController
      include Api::V1::Concerns::Response
      include Api::V1::Concerns::Push

      def index
        auth_user and return

        user = User.where(authentication_token: request.headers[:token]).select("id AS user_id, name, email")
        friends = []
        if params[:type].to_i == 1
          result = Friend.where(user_id: user.first.user_id)
          last_tink = Tink.where(user_id: user.first.user_id, recipient_id: user.first.user_id).select("created_at").last
          friends << {"user_id" => user.first.user_id, "name" => user.first.name, "email" => user.first.email, "last_tink_created_at" => (last_tink.present? ? last_tink.created_at.strftime("%FT%T%:z") : '')}
        else
          result = Friend.where(friend_id: user.first.user_id)
        end

        result.each do |friend|
          if params[:type].to_i == 1
            fr = User.where(id: friend.friend_id).select("id AS user_id, name, email").first
            last_tink = Tink.where(user_id: user.first.user_id, recipient_id: friend.friend_id).select("created_at").last
          else
            fr = User.where(id: friend.user_id).select("id AS user_id, name, email").first
            last_tink = Tink.where(user_id: friend.user_id, recipient_id: user.first.user_id).select("created_at").last
          end
          friends << {"user_id" => fr.user_id, "name" => fr.name, "email" => fr.email, "last_tink_created_at" => (last_tink.present? ? last_tink.created_at.strftime("%FT%T%:z") : '')}
        end

        success_response({friends: friends})
      end

      def invite
        auth_user and return

        user = User.where(authentication_token: request.headers[:token])

        return error_response("Invitee's email is requred", 102) unless params[:email].present?
        #return error_response("User has already been invited", 103) if Invite.where(invitee: params[:email]).present?

        Invite.create(user_id: user.first.id, invitee: params[:email])

        FriendMailer.send_invite(user, params[:email])
      end

      def create
        auth_user and return

        user = User.where(authentication_token: request.headers[:token])

        return error_response('Friend id is required', 103) unless params[:friend_id].present?
        return error_response('User you want to befriend does not exists', 104) if User.where(id: params[:friend_id]).blank?
        return error_response('Can not befriend yourself', 105) if user.first.id == params[:friend_id].to_i
        return error_response('You are already friends with this user', 106) unless Friend.where(user_id: user.first.id, friend_id: params[:friend_id]).blank?

        friend = Friend.create(user_id: user.first.id, friend_id: params[:friend_id])



        color = get_color(params[:friend_id])
        text = "#{user.first.name} just added you."
        Tink.create(user_id: user.first.id, recipient_id: params[:friend_id], read: 0, color: color, text: text)

        ApnsToken.where(user_id: params[:friend_id]).each do |t|
          send_push_notification(t.token, params[:tink][:recipient_id], text)
        end

        success_response({user_id: friend[:user_id], friend_id: friend[:friend_id], text: text})
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
