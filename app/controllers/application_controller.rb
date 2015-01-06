class ApplicationController < ActionController::API
  include ActionController::MimeResponds

  respond_to :json
  skip_before_filter :authenticate_user!

  protected

  def user_params
    params[:user].permit(:email, :password, :password_confirmation)
  end
end
