module Api
  module V1
    class Api::V1::ApiController < ApplicationController
      respond_to :json
      skip_before_filter :authenticate_user!

      protected

      def user_params
        params[:user].permit(:email, :name, :password, :password_confirmation)
      end
    end
  end
end
