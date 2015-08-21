class PagesController < BaseController

  def confirm_email

    if User.where(email_confirmation_code: params[:id]).present?
      User.where(email_confirmation_code: params[:id]).update_all(active: 1)
      @text = '<b>Profile completed!</b><br><br> When you <a href="https://itunes.apple.com/us/app/tinkchat/id939420577">sign in</a> we will show you how to add and tink your friends.'
    else
      @text = 'Problems with account activation. Please, try again.'
    end
    render :layout => false
  end

  def sendmessage
    if Contact.new(message_params).valid?
      ContactMailer.forward_contact_message(message_params)
    end
    redirect_to root_path
    return
  end

  def contact
    if params[:subject] == 'Android'
      @value = 'I want an Android version of Tinkchat'
    else
      @value = params[:subject]
    end
  end

  private
    def message_params
      final_params = params.permit(:subject, :email, :message)
      final_params
    end
end
