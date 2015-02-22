class PagesController < BaseController
  def confirm_email
    if User.where(email_confirmation_code: params[:id]).present?
      User.where(email_confirmation_code: params[:id]).update_all(active: 1)
      @text = 'Your email address has been confirmed.'
    else
      @text = 'Problems with account activation. Please, try again.'
    end
  end

  def sendmessage
    if Contact.new(message_params).valid?
      ContactMailer.forward_contact_message(message_params).deliver
    end
    redirect_to root_path
    return
  end

  private
    def message_params
      final_params = params.permit(:subject, :email, :message)
      final_params
    end

end
