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
          amount = Tink.where(user_id: user.first.user_id, recipient_id: user.first.user_id).count
          friends << {
            "user_id" => user.first.user_id,
            "name" => user.first.name,
            "email" => user.first.email,
            "last_tink_created_at" => (last_tink.present? ? last_tink.created_at.strftime("%FT%T%:z") : ''),
            "amount_to" => amount,
            "amount_from" => amount,
          }
        else
          result = Friend.where(friend_id: user.first.user_id)
        end

        result.each do |friend|
          if params[:type].to_i == 1
            fr = User.where(id: friend.friend_id).select("id AS user_id, name, email").first
            last_tink = Tink.where(user_id: user.first.user_id, recipient_id: friend.friend_id).select("created_at").last
            amount_to = Tink.where(user_id: user.first.user_id, recipient_id: friend.friend_id).count
            amount_from = Tink.where(user_id: friend.friend_id, recipient_id: user.first.user_id).count
          else
            fr = User.where(id: friend.user_id).select("id AS user_id, name, email").first
            last_tink = Tink.where(user_id: friend.user_id, recipient_id: user.first.user_id).select("created_at").last
            amount_to = Tink.where(user_id: user.first.user_id, recipient_id: friend.user_id).count
            amount_from = Tink.where(user_id: friend.user_id, recipient_id: user.first.user_id).count
          end
          friends << {
            "user_id" => fr.user_id,
            "name" => fr.name,
            "email" => fr.email,
            "last_tink_created_at" => (last_tink.present? ? last_tink.created_at.strftime("%FT%T%:z") : ''),
            "amount_to" => amount_to,
            "amount_from" => amount_from,
          }
        end

        success_response({friends: friends})
      end

      def invite
        auth_user and return

        user = User.where(authentication_token: request.headers[:token])

        return error_response("Invitee's email is requred", 102) unless params[:email].present?
        return error_response("You can not invite yourself", 103) if user.first.email == params[:email]

        friend = User.where(email: params[:email])
        if friend.present?
          return error_response('You are already friends with this user', 104) unless Friend.where(user_id: user.first.id, friend_id: friend.first.id).blank?
          new_friend(user, friend.first.id)
        else
          Invite.create(user_id: user.first.id, invitee: params[:email])
          FriendMailer.send_invite(user, params[:email])
        end
      end

      def create
        auth_user and return

        user = User.where(authentication_token: request.headers[:token])

        return error_response('Friend id is required', 103) unless params[:friend_id].present?
        return error_response('User you want to befriend does not exists', 104) if User.where(id: params[:friend_id]).blank?
        return error_response('Can not befriend yourself', 105) if user.first.id == params[:friend_id].to_i
        return error_response('You are already friends with this user', 106) unless Friend.where(user_id: user.first.id, friend_id: params[:friend_id]).blank?

        new_friend(user, params[:friend_id])
        success_response({user_id: user.first.id, friend_id: params[:friend_id]})
      end

      def destroy
        auth_user and return

        user = User.where(authentication_token: request.headers[:token])

        return error_response('Friend id is required', 103) unless params[:id].present?
        return error_response('User does not exists', 104) if User.where(id: params[:id]).blank?
        return error_response('You are not friends with this user to begin with', 105) if Friend.where(user_id: user.first.id, friend_id: params[:id].to_i).blank?

        Friend.where(user_id: user.first.id).where(friend_id: params[:id]).delete_all
      end

      def new_friend(user, friend_id)
        Friend.create(user_id: user.first.id, friend_id: friend_id)
        color = get_color(friend_id)
        text = "#{user.first.name} just added you."
        Tink.create(user_id: user.first.id, recipient_id: friend_id, read: 0, color: color, text: text)

        ApnsToken.where(user_id: friend_id).each do |t|
          send_push_notification(t.token, friend_id, text)
        end
      end

    end
  end
end
