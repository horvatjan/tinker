class ApplicationController < ActionController::API

  include ActionController::MimeResponds
  include Api::V1::Concerns::Response

  respond_to :json
  skip_before_filter :authenticate_user!

  def auth_user
    user = User.where(authentication_token: request.headers[:token])
    return error_response('Token invalid', 101) unless user.present?
    return error_response('Token invalid', 101) unless (Time.now <= user.first.token_expiration ? true : false)
  end

  protected

  def user_params
    params[:user].permit(:email, :password, :password_confirmation, :username)
  end
end
