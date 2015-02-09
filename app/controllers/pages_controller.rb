class PagesController < BaseController
  def confirm_email
    if User.where(email_confirmation_code: params[:id]).present?
      User.where(email_confirmation_code: params[:id]).update_all(active: 1)
      @text = 'Your email address has been confirmed.'
    else
      @text = 'Problems with account activation. Please, try again.'
    end
  end
end
